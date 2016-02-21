package PCA_XMLParser;




#############################################################################
# return the Section in the form <StartTag>XXX</EndTag>. 
# of a field given TAG
# input : (<TAG1>data1</TAG1><TAG2>data2></TAG2> , <TAG2>,</TAG2>)
# output : <TAG2>data1</TAG2>
#############################################################################


sub GetTagSection
{
	
	my $XMLString = shift; 
	my $StartTag = shift;
	my $EndTag = shift;
	
	
  	my $StartPos = index($XMLString,$StartTag) ; 
  	if ($StartPos == -1 )
  	{
    		$Msg = "GetTagSection -- StartTag Not Found !";
    		print $Msg;
    		return -1;
    	}
    		
    		
       
        my $EndPos = index($XMLString,$EndTag)  ;
  	if ($EndPos == -1 )
  	{
    		$Msg = "GetTagSection -- EndTag Not Found !"   ;
    		print $Msg; 
    		return -1;
    	}	
  	#print "EndPos = $EndPos\n"  ; 	
 	
  	$Field = substr($XMLString,$StartPos,($EndPos-$StartPos)+length($EndTag));  	
  	
  	
  	return $Field,substr($XMLString,$EndPos+length($EndTag))


}	
  	
  	
##########################################################################
# return the value of a given TAG from a given XML String. 
# 
##########################################################################

sub GetXMLTagValue
{
	
	my $XML_String = shift; 
	my $Tag = shift; 
	
	my $StartTag = sprintf ("<%s>",$Tag);
	my $EndTag = sprintf ("</%s>",$Tag);
  	
  	my ($MyValue,$CMD) = GetTagSection($XML_String,$StartTag,$EndTag);
  	
  	
  	
  	
  	$Field = GetTagValue($MyValue);
  	
  	
   	
   	$Field =~ s/^\s+//;
	$Field =~ s/\s+$//;
   	
   	return $Field;   	
}


##########################################################################
# return the value of a field given in the form <TAG>XXX</TAG>. 
# XXX will be returned in this case.
##########################################################################

sub GetTagValue
{
	
	my $XMLString = shift; 	
	
	my $StartPos = index($XMLString,">")  ;
  	if ($StartPos == -1 )
  	{    		  
    		print "GetTagValue -- StartTag Not Found !\n";
    		
    		return -1;
    	}    		
    	
    	my $TMP_XMLString = substr($XMLString,$StartPos+1,length($XMLString)-1);
    	
    	my $EndPos = index($TMP_XMLString,"<")  ;
  	if ($EndPos == -1 )
    	{    		  
    		print "GetTagValue -- EndTag Not Found !\n";
    		
    		return -1;
    	}  	
	
	
	
  	$Field = substr($XMLString,$StartPos+1,$EndPos);  	
  	
  	return $Field;
	
}
	

1;


