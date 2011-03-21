use sm;


my $oSendMail = sm->new(
                                                );  

                $oSendMail->send_email(
                        "subject" => "copy failed: cp -f $from $to!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
                        "text" => "copy failed: cp -f $from $to, please manual copy the file!\n",
                        "to" => 'matthewatmezi@gmail.com, matthewatmezi@gmail.com');
