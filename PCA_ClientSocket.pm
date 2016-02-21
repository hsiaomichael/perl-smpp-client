package PCA_ClientSocket;

use PCA_GenLib;
use PCA_XMLParser;
use IO::Socket;
use IO::Select;
use Socket;


##############################################################
#
##############################################################
sub Connector
{

	my $self = {};
   	bless($self);
   	shift;
           	
       
	$Msg = "Connector Init ...";
	PCA_GenLib::WriteLog($Msg,9);
	
	 
        $self->{XMLCFG} = shift;
        
        
        $Msg = sprintf("XMLCFG = %s", $self->{XMLCFG});
	PCA_GenLib::WriteLog($Msg,8);
	
	
	my $Tag = "REMOTE_HOST";
	$self->{HOST}  = PCA_XMLParser::GetXMLTagValue($self->{XMLCFG},$Tag);
			
			
	$Tag = "REMOTE_PORT";
	$self->{PORT} = PCA_XMLParser::GetXMLTagValue($self->{XMLCFG},$Tag);
			
	$Msg = sprintf("Remote Host=<%s>,Port=<%s>",$self->{HOST},$self->{PORT});
	PCA_GenLib::WriteLog($Msg,1);
			
    			
    	$Msg = "Connector Initial Ok ";
	PCA_GenLib::WriteLog($Msg,9);
	   
   	return $self;
	
}


##############################################################
#
##############################################################
sub connect
{
	
	$self = shift;	
	
	$self->{SERVER} = IO::Socket::INET->new
	(
		PeerAddr => $self->{HOST},
		PeerPort => $self->{PORT},
		Proto => 'tcp',
		Type => SOCK_STREAM
	);
	
	if ( $self->{SERVER} )
	{
		$Msg = "success connect to server";
		PCA_GenLib::WriteLog($Msg,1);
		
		
	
		$self->{SOCKET_HANDLE_SET} = IO::Select->new();
		$self->{SOCKET_HANDLE_SET}->add($self->{SERVER});
		
		return 1;
	}
	else
	{
		$Msg = "can not connect to server";
		PCA_GenLib::WriteLog($Msg,1);
		return 0;
	}

	
}



##############################################
##
##############################################
sub readDataFromSocket
{

	$Msg = "readDataFromSocket ";
	PCA_GenLib::WriteLog($Msg,9);
	
	$self = shift;	
	my $Length = shift;
	my $TimeOut = shift;
	my $ReadAttempts = shift;
			
	for ($i = 0 ; $i < $ReadAttempts ; $i++)
	{
		($client_socket_read_set) = IO::Select->select($self->{SOCKET_HANDLE_SET}, undef, undef, $TimeOut);
	
		foreach $client_socket_fd (@$client_socket_read_set)
		{
			if ($client_socket_fd == $self->{SERVER})
			{
				
				$numClientBytesRead = sysread($client_socket_fd,  $self->{MESSAGE},$Length);
			
				if( defined($numClientBytesRead ))
				{
					$Msg = "ReadDataFromSocket OK";
					PCA_GenLib::WriteLog($Msg,3);
					
					return $self->{MESSAGE};
				}
				else
				{
					$Msg = "Client Close Connection ";
					PCA_GenLib::WriteLog($Msg,1);
					$self->{SOCKET_HANDLE_SET}->remove($client_socket_fd);					
					
					close($client_socket_fd);
						
					return "0";
				}
				
			}
		}
				
	}		
	
	$Msg = "readDataFromSocket retry time out !";
	PCA_GenLib::WriteLog($Msg,6);
	
	return "-1";
	
}			



##############################################
##
##############################################
sub sendDataToSocket
{

	$Msg = "sendDataToSocket ";
	PCA_GenLib::WriteLog($Msg,9);
	
	$self = shift;
	
	my $Message = shift;
	my $TimeOut = shift;
	my $WriteAttempts = shift;	
	
			
	for ( $i = 0 ; $i < $WriteAttempts ; $i++)
	{
		
		($client_socket_read_set,$client_socket_write_set) = IO::Select->select(undef,$self->{SOCKET_HANDLE_SET}, undef, $TimeOut);
		
		foreach $client_socket_fd (@$client_socket_write_set)
		{
			if ($client_socket_fd == $self->{SERVER})
			{
				
				$Msg = "Send data to server , message = <$Message>";
				PCA_GenLib::WriteLog($Msg,2);
					
				$client_socket_fd->send($Message);
				
				return 1;
				
			}
		}	
	}
	
		
	$Msg = "sendDataToSocket retry time out !";
	PCA_GenLib::WriteLog($Msg,6);
	
	return -1;
	
}			


##############################################
##
##############################################
sub close
{
	
	$self = shift;
	
	$Msg = "close connector socket";
	PCA_GenLib::WriteLog($Msg,1);
	
	close($self->{SERVER});
	
}	
	

1;
