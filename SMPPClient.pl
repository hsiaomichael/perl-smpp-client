#!/usr/bin/perl -w

use lib './';

use warnings;
use Env;
use PCA_GenLib;
use IO::File;
use PCA_ClientSocket;
use File::Basename;


##########################################################
#### Main Process Start                              #####
##########################################################


sub Execute
{
        my $SMPP_Connection = shift;
        my $Message = shift;

        my $Length = 1024;
        my $TimeOut = 8.0;
        my $ReadAttempts = 2;

        $Msg = sprintf ("send to server data = \n%s\n",PCA_GenLib::HexDump($Message));
        PCA_GenLib::WriteLog($Msg,1);

        $status = $SMPP_Connection->sendDataToSocket($Message,$TimeOut,$ReadAttempts);

        if ($status == 1)
        {
                $Message = $SMPP_Connection->readDataFromSocket($Length,$TimeOut,$ReadAttempts);

                if ($Message eq "0")
                {
                        $Msg = "read from server socket error , server close connection";
                        PCA_GenLib::WriteLog($Msg,0);
                        return "-1";
                }
                elsif ($Message eq "-1")
                {
                        $Msg = "read from server timeout";
                        PCA_GenLib::WriteLog($Msg,0);
                }
                else
                {
                        $Msg = sprintf ("read from server ok data = \n%s\n",PCA_GenLib::HexDump($Message));
                        PCA_GenLib::WriteLog($Msg,0);
                }
        }
        else
        {
                $Msg = "Send failure";
                PCA_GenLib::WriteLog($Msg,0);
                return "-1";
        }

        return $Message;
}

####################################################
#
####################################################
sub MainTest
{

        $XMLCFG = shift;
        $a_party = shift;
        $b_party = shift;
        $sms_text = shift;

        PCA_GenLib::DBXMLCFGInit($XMLCFG);

        $SMPP_Connection = PCA_ClientSocket->Connector($XMLCFG);

        $status = $SMPP_Connection->connect();

        if ($status == 0)
        {
                $Msg = "-----------------------------------------------------------------------------------";
                PCA_GenLib::WriteLog($Msg,0);

                $Msg = "Close debug log....";
                PCA_GenLib::WriteLog($Msg,0);

                PCA_GenLib::CloseLog();
                return;
        }

        $Msg = "-----------------------------------------------------------------------------------";
        PCA_GenLib::WriteLog($Msg,0);

        $command_id = pack("N",2);
        $command_status = pack("N",0);
        $sequence_number = pack("N",0);
        $system_id = "SMPP_EXT" . chr(0x00);
        $password = "pooky" . chr(0x00);
        $system_type = "" . chr(0x00);
        $interface_version =  chr(0x34);
        $addr_ton =  chr(0x01);
        $addr_npi =  chr(0x01);
        $address_range =  chr(0x01).chr(0x00);

        $Bind_Message =  $command_id . $command_status . $sequence_number . $system_id . $password . $system_type . $interface_version . $addr_ton . $addr_npi . $address_range ;

        $MessageLength = length($Bind_Message) + 4;
        $command_length = pack("N",$MessageLength);

        $Message = $command_length . $Bind_Message;

        $Msg = "######################################################################";
        PCA_GenLib::WriteLog($Msg,0);
        $Msg = "###############   Send Bind Request To SMPP  #########################";
        PCA_GenLib::WriteLog($Msg,0);
        $Msg = "######################################################################";
        PCA_GenLib::WriteLog($Msg,0);

        $Message = Execute($SMPP_Connection,$Message);

        if ($Message eq "-1")
        {
                $Msg = "socket error . during send bind request ";
                PCA_GenLib::WriteLog($Msg,0);

        }
        else
        {
                $Msg = "######################################################################";
                PCA_GenLib::WriteLog($Msg,0);
                $Msg = "###############   Recv Bind Response From SMPP  ######################";
                PCA_GenLib::WriteLog($Msg,0);
                $Msg = "######################################################################";
                PCA_GenLib::WriteLog($Msg,0);

                $command_status = substr($Message,8,4);
                $bind_response = unpack("N",$command_status);


                if  ($bind_response == 0)

                {
                        $Msg = "Bind Response , successful  ";
                        PCA_GenLib::WriteLog($Msg,0);


                        $Msg = "######################################################################";
                        PCA_GenLib::WriteLog($Msg,0);
                        $Msg = "###############   Send SubmitSM To SMPP        #######################";
                        PCA_GenLib::WriteLog($Msg,0);
                        $Msg = "######################################################################";
                        PCA_GenLib::WriteLog($Msg,0);

                        $command_id = pack("N",4);
                        $command_status = pack("N",0);
                        $sequence_number = pack("N",66);
                        $service_type = chr(0x00);
                        $source_addr_ton = chr(0x01);
                        $source_addr_npi = chr(0x01);
                        $source_addr = $a_party . chr(0x00);
                        $dest_addr_ton = chr(0x01);
                        $dest_addr_npi = chr(0x01);
                        $dest_addr = $b_party . chr(0x00);
                        $esm_class = chr(0x00);
                        $protocol_id = chr(0x00);
                        $priority_flag = chr(0x00);
                        $schedule_delivery_time = chr(0x00);
                        $validity_period = chr(0x00);
                        $registered_delivery = chr(0x00);
                        $replace_if_present_flag = chr(0x00);
                        $data_coding = chr(0x00);
                        $sm_default_msg_id = chr(0x00);
                        $sm_length = chr(length($sms_text)) ;
                        $short_message = $sms_text ;


                        $SubmitSM_Message =  $command_id . $command_status . $sequence_number . $service_type . $source_addr_ton . $source_addr_npi . $source_addr . $dest_addr_ton . $dest_addr_npi . $dest_addr . $esm_class . $protocol_id . $priority_flag . $schedule_delivery_time . $validity_period . $registered_delivery . $replace_if_present_flag . $data_coding . $sm_default_msg_id . $sm_length . $short_message ;


                        $MessageLength = length($SubmitSM_Message) + 4;
                        $command_length = pack("N",$MessageLength);

                        $Message = $command_length . $SubmitSM_Message;


                        $Message = Execute($SMPP_Connection,$Message);
                        if ($Message eq "-1")
                        {
                                $Msg = "socket error .during send submit_sm request ";
                                PCA_GenLib::WriteLog($Msg,0);

                        }
                        else
                        {
                                $Msg = "######################################################################";
                                PCA_GenLib::WriteLog($Msg,0);
                                $Msg = "###############   Recv Submit SM Response From SMPP ##################";
                                PCA_GenLib::WriteLog($Msg,0);
                                $Msg = "######################################################################";
                                PCA_GenLib::WriteLog($Msg,0);


                                $Msg = "######################################################################";
                                PCA_GenLib::WriteLog($Msg,0);
                                $Msg = "###############   Send Unbind to SMPP               ##################";
                                PCA_GenLib::WriteLog($Msg,0);
                                $Msg = "######################################################################";
                                PCA_GenLib::WriteLog($Msg,0);

                                $command_id = pack("N",6);
                                $command_status = pack("N",0);
                                $sequence_number = pack("N",99);

                                $UnBind_Message =  $command_id . $command_status . $sequence_number ;

                                $MessageLength = length($UnBind_Message) + 4;
                                $command_length = pack("N",$MessageLength);

                                $Message = $command_length . $UnBind_Message;

                                $Message = Execute($SMPP_Connection,$Message);

                        }


                }
                else
                {
                        $Msg = "Bind Failure ";
                        PCA_GenLib::WriteLog($Msg,0);


                }


        }

        $Msg = "-----------------------------------------------------------------------------------";
        PCA_GenLib::WriteLog($Msg,0);

        $SMPP_Connection->close();

        $Msg = "Close debug log....";
        PCA_GenLib::WriteLog($Msg,0);

        PCA_GenLib::CloseLog();
}


############################### Main Program ############################################


$program_name = basename($0);

if (@ARGV < 4)
{
        print "Usage : $program_name [cfg file name] [source address] [destination address] [SMS Text]\n";
        exit;
}


$cfg_file_name = $ARGV[0];
$source_address = $ARGV[1];
$destination_address = $ARGV[2];
$SMSText = $ARGV[3];


open(CFG_FILE_HANDLE,$cfg_file_name);
read(CFG_FILE_HANDLE,$XMLCFG,1024);
close(CFG_FILE_HANDLE);


print "Your file name =  $cfg_file_name \n";


#$XMLCFG =  open(cfg_file_name,"r").read()



MainTest($XMLCFG,$source_address,$destination_address,$SMSText);





