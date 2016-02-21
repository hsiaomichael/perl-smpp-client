package PCA_Parser;

use PCA_GenLib;

##############################################################
#
##############################################################
sub Parser
{

	my $self = {};
   	bless($self);
   	shift;
   	
   	$self->{CONTENT_HANDLER} = '';
           	
        return $self;
	
}



##############################################################
#
##############################################################
sub parse
{
	
	$self = shift;	
	my $source = shift;

	
	$Msg = "parser init";
	PCA_GenLib::WriteLog($Msg,9);
	
	
	$Msg = "parser ok";
	PCA_GenLib::WriteLog($Msg,9);
}



sub set_handler
{	
	
	$self = shift;	
	
	
	my $name = shift;
	my $attrs = shift;
	my $content = shift;
	
		
	$self->{CONTENT_HANDLER}->startElement($name, $content);    		
        $self->{CONTENT_HANDLER}->characters($content);
        $self->{CONTENT_HANDLER}->endElement($name);
}
 
#############################################################
#
##############################################################
sub getContentHandler
{
	
	$self = shift;	
	
	$Msg = "getContentHandler init";
	PCA_GenLib::WriteLog($Msg,9);
	
	
	$Msg = "getContentHandler ok";
	PCA_GenLib::WriteLog($Msg,9);
	
	return $self->{CONTENT_HANDLER};
}


#############################################################
#
##############################################################
sub setContentHandler
{
	
	$self = shift;	
	$self->{CONTENT_HANDLER} = shift;
	
	$Msg = "setContentHandler init";
	PCA_GenLib::WriteLog($Msg,9);
	
	
	$Msg = "getContentHandler ok";
	PCA_GenLib::WriteLog($Msg,9);
}

1;
