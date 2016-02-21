package PCA_GenLib;

use Env;
use PCA_XMLParser;

use Time::HiRes qw(gettimeofday);



$PrintDebugLogLevel = 0;             # Set default debug level
$PrintDebug = 0;             # Debug to stdout defaults to off
$log_debug = 0;               # Log debug to file defaults to off
$prog_name = "";              # Program name
$FileLineNo = 0;
$FileNameSeqNo = 1;



sub OpenLog
{
			
	open(LOGFILE,">$DebugLogFileName");
	my $Msg = sprintf("Debug level = <%s>, Debug log = <%s>" ,$PrintDebugLogLevel ,$DebugLogFileName);
	WriteLog($Msg,0);
		
}


################################################################
# Name: DbInit
#
# Set up debug, open debug file and print header
#
sub DBXMLCFGInit
{
	$XMLCFG = shift;
	#print "DEBUG  $XMLCFG\n";
	
	my $Tag = "DLOG";
		
		
	
	
	$filename = PCA_XMLParser::GetXMLTagValue($XMLCFG,$Tag);
	
	
	my $process_id = getppid();
	
	my $tmp_filename = substr($filename,-1);
	if ( $tmp_filename eq "+")
	{
					
		$DebugLogFileName = sprintf("%s.%05d",substr($filename,0,length($filename)-1),$process_id);
	}
	else
	{
		$DebugLogFileName = $filename;
	}	
	
	#print " DebugLogFileName = <$DebugLogFileName>\n";
	
	
	$Tag = "DLVL";
	$PrintDebugLogLevel = PCA_XMLParser::GetXMLTagValue($XMLCFG,$Tag);
	
	#print " DebugLogLevel = <$PrintDebugLogLevel>\n";
	
	$Tag = "DB_FLUSH";
	$FlushFile = PCA_XMLParser::GetXMLTagValue($XMLCFG,$Tag);
	
	#print " FlushFile = <$FlushFile>\n";
	
	$Tag = "DB_PRINT";
	$PrintDebug = PCA_XMLParser::GetXMLTagValue($XMLCFG,$Tag);
	
	#print " PrintDebug = <$PrintDebug>\n";
	
	
	OpenLog();
    	
}


################################################################
# Name: UsrHandler
#
# Changes the debug level on receipt of a SIGUSR
#
# Parameters:
#  sig   - USR1 or USR2
#
sub UsrHandler {

    local ($sig)= @_;

    if ($sig eq "USR1")
    {
        $debug = 1;
        $debug_level++ if $debug_level < 9;
    }
    elsif ($sig eq "USR2")
    {
        $debug_level-- if $debug_level > -2;
    }

    Info("Debug level Changed to $debug_level");

}

################################################################
# Name: Debug
#
# Prints debug to debug log
#
# Parameters:
#  level - -2 -> 9
#  text  - text to print
#
sub WriteLog
{
  
    local ($text,$level) = @_;
    if ($level <= $PrintDebugLogLevel)
    {
        # format debug level string
        $dbglvl="ERR"      if ( $level == -2 );
        $dbglvl="WAR"      if ( $level == -1 );
        $dbglvl="INF"      if ( $level ==  0 );
        $dbglvl="DB$level" if ( $level >   0 );

        # format output string
        ($epochseconds, $microseconds) = gettimeofday;
        ($sec,$min,$hour,$mday,$mon,$year,$x,$x,$x) = localtime($epochseconds);
        
        
        ($package,$filename,$line) = caller;
		
	#print "DEBUG : package=<$package>,filename=<$filename>,lines=<$line>\n";
     
	
	@short_filename = split(/\//,$filename);
       	$dbgtext = sprintf("%04d-%02d-%02d %02d:%02d:%02d.%06d %s %s(%s) [%s]\n",
        $year+1900,$mon+1,$mday,   $hour, $min, $sec,$microseconds,
        $dbglvl,$short_filename[-1],$line, $text);
        
     	
        print $dbgtext if $PrintDebug;
        print LOGFILE $dbgtext;
        
        
        $MaxRecordInOneDebugLogFile = 10000;
        $FileLineNo = $FileLineNo + 1	;
	if ($FileLineNo > $MaxRecordInOneDebugLogFile)
	{			
		$Arcihve_DebugFileName = sprintf("%s.%s" ,$DebugLogFileName,$FileNameSeqNo);
		$FileNameSeqNo = $FileNameSeqNo + 1;
		$Msg = sprintf("Debug Log File more than %s records , rename <%s> to <%s>\n",$MaxRecordInOneDebugLogFile,$DebugLogFileName,$Arcihve_DebugFileName);
		#print "DEBUG $Msg\n";
		print LOGFILE $Msg;
		close(LOGFILE);
		
		unlink($Arcihve_DebugFileName);
		rename($DebugLogFileName,$Arcihve_DebugFileName);	
		$FileLineNo = 0;	
		OpenLog();
	}
		
    }
}


sub Info
{
    local ($text) = @_;
    Debug(0, $text);
}


sub Warning
{
    local ($text) = @_;
    Debug(-1, $text);
}


sub Error
{
    local ($text) = @_;
    Debug(-2,$text);
}


sub CloseLog
{
    LOGFILE.close();
}
################################  add by Michael Hsiao 2004 01 29 ##########



#####################################################
sub ExecuteCMD
{
 $System_Cmd = shift;

  $TestFlag  = shift;
  if ( $TestFlag )
  {
	Info("Test Only CMD = $System_Cmd");
	return 0
  }


  if ($System_Cmd)
  {
    Debug(9, "Execute System Command => <$System_Cmd>");    
    if (system($System_Cmd))
    {
      Warning("Fail to Execute system Command !");
    }
    else
    {
      Info("Command ok !");
    }
  }# end of System
}


################################################   	
####  If Process still executing then exit #####
################################################

sub CheckProcess
{
   ##$ProgramName = "psa_cdredr.pl";
   $ProgramName = shift;
   if ( not (-e "/usr/bin/ps") )
   {
     print "ps not exists\n";
     return 1 ;
   }
   $ProcessCount = 0;
   $CMD = "ps -ef|grep  $ProgramName |grep -v grep| ";   
   open (MYSHELL,$CMD) || die("command error < $CMD > : $!");
   while (<MYSHELL>)
   {
     $ProcessCount++;     
     #print "ps output  :$_ \n";   
   }
   close MYSHELL;
   #print "Process Count = <$ProcessCount> \n";
   
   
   if ($ProcessCount >=2)
   {
     #print "Process Running Exit ! \n";  
     return -1;
   }
   return 1;
}   

###################################################
##### Check Informix Database in On-Line state ####
###################################################
sub CheckInformix
{			
   $InformixPattern = "On-Line";   
   if ( not (-e "/home/informix/bin/onstat") )
   {
     print "onstat not exists \n";
     return 1 ;
   }
   $CMD = "/home/informix/bin/onstat - |grep $InformixPattern|";   
   $ProcessCount = 0;
   open (MYSHELL,$CMD) || die("command error < $CMD > : $!");
   while (<MYSHELL>)
   {
     $ProcessCount++;   
     #print "Informix State:$_ \n";    
   }
   close MYSHELL;
   
   if ($ProcessCount >=1)
   {
     #print "Informx State On-Line continue execute this program\n";  
     return 1;   
   }
   else
   {
     print "Informix Database Off Exit Program!\n";
     return -1;
   }
  

}
###########################################################   

sub ToASCII
{
	$data1 = shift;
	@data = split("",$data1);
	
   	@Result = ();
        @ascii_data = map(ord,@data);
        foreach  $a (@ascii_data)
        {        	
        	@Result  = (@Result,$a);
        }
	return @Result;
 	
 
} 
########################################################		
## convert ascii to hex and character format	      ##
## retur a string (just print it for debug )	      ##
######################################################## 
sub HexDump
{
	$data = shift;
	
	
	@ASCIIData = ToASCII($data);
	
	
	@chr_list = ();
	@DebugString = ();
   	$new_line = 8;
       	 
       	 foreach $ascii_value ( @ASCIIData )
       	 {
       	 	if ($new_line == 8)
       		{      	 			
       			@DebugString = ( @DebugString,"[" );
		}	
       		
       		#$hex_data = hex($ascii_value);
       		$hex_data = sprintf("%02x",$ascii_value);
       		if (length($hex_data) == 1)
       		{
        		$hex_data = "0".substr($hex_data,-1);
        	}        	
		else
		{
        		$hex_data = $hex_data;
		}	
		
        	@DebugString = (@DebugString,$hex_data)  ;  
        	$chr_val = chr($ascii_value);    
        	if( not ( ord($chr_val) >= 48 and ord($chr_val) <= 57 ) ||  ( ord($chr_val) >= 65 && ord($chr_val) <= 90 ) || ( ord($chr_val) >= 97 && ord($chr_val) <= 122 ) )
        	{
        		$chr_val = ' ';
        	}
        	
        	@chr_list = (@chr_list ,"|") ;
        	
        	$new_line = $new_line - 1;
        	if ( $new_line == 0)
        	{
        		$new_line = 8;
        		
        		@DebugString = (@DebugString ,"] ==> ");    
        		
        		@DebugString = ( @DebugString,@chr_list);
        		@DebugString = ( @DebugString,"\n");
        		@chr_list = ();
        	}
        	
        }	
        
        if ($new_line > 0 && $new_line < 8)
        {
        	for ($i=0; $i<$new_line ; $i++)
        	{        			
        		@DebugString = (@DebugString,"    ");
        		
        	}
        	
        	@DebugString = (@DebugString,"] ==> ");
	}	    
	    		
        @DebugString = (@DebugString , @chr_list);
        $Data = join(" " , @DebugString);
        
        return " ".$Data;
	
 }

######################################################
#
######################################################	
sub AsciiToBCD
{
	my $data = shift;
	
	
	@ascii_char = split("",$data);
	
	
	$bcd_char = '';
	$i = 1;
	$Length = 0;
	
	foreach $code ( @ascii_char )
	{		
			
		if ($i == 1)
		{
			$data1 = ( ord($code) << 4 ) & ord( chr(0xF0) ) ;
			$i = $i + 1;
			$Length = $Length + 1;
		}
					
		else
		{
			$data2 = ( ord($code) << 4 ) & ord( chr(0xF0) ) ;
			$data = $data1 ^ ($data2 >> 4);
			$bcd_char = $bcd_char.chr($data);
			$i = 1;
			$Length = $Length + 1;
					
		}
	}	
	if ($i == 2)
	{
		$bcd_char = $bcd_char.chr($data1);
	}
		
	$padding_length = 8 - length($bcd_char);
			
	for ( $i=0 ; $i < $padding_length ; $i++ )
	{
		$bcd_char = $bcd_char.chr(00);
	}
				
		
	
	return $Length,$bcd_char
		
}

1;
