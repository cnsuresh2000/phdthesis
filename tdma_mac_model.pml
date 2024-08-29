#define NONLOSSY
#define MESSAGE_COLLISION
#define P1
#define DESIGNERROR 1
#define n0_s1 (Node0@n0_slot_begin)
#define n0_s2 (Node0@n0_ts_msgorigin_rt)
#define n0_s3 (Node0@n0_ts_msgorigin_nrt)
#define n0_s4 (Node0@n0_ts_fw_rt)
#define n0_s5 (Node0@n0_ts_fw_nrt)
#define n0_s6 (Node0@n0_ts_wait_for_ack)
#define n0_s7 (Node0@n0_ts_ack_loss)
#define n0_s8 (Node0@n0_ts_ack_recvd)
#define n0_s9 (Node0@n0_rs)
#define n0_s10 (Node0@n0_rs_msg_loss) 
#define n0_s11 (Node0@n0_rs_msg_recvd)
#define n1_s1 (Node1@n1_slot_begin)
#define n1_s2 (Node1@n1_ts_msgorigin_rt)
#define n1_s3 (Node1@n1_ts_msgorigin_nrt)
#define n1_s4 (Node1@n1_ts_fw_rt)
#define n1_s5 (Node1@n1_ts_fw_nrt)
#define n1_s6 (Node1@n1_ts_wait_for_ack)
#define n1_s7 (Node1@n1_ts_ack_loss)
#define n1_s8 (Node1@n1_ts_ack_recvd)
#define n1_s9 (Node1@n1_rs)
#define n1_s10 (Node1@n1_rs_msg_loss) 
#define n1_s11 (Node1@n1_rs_msg_recvd)
#define n2_s1 (Node2@n2_slot_begin)
#define n2_s2 (Node2@n2_ts_msgorigin_rt)
#define n2_s3 (Node2@n2_ts_msgorigin_nrt)
#define n2_s4 (Node2@n2_ts_fw_rt)
#define n2_s5 (Node2@n2_ts_fw_nrt)
#define n2_s6 (Node2@n2_ts_wait_for_ack)
#define n2_s7 (Node2@n2_ts_ack_loss)
#define n2_s8 (Node2@n2_ts_ack_recvd)
#define n2_s9 (Node2@n2_rs)
#define n2_s10 (Node2@n2_rs_msg_loss) 
#define n2_s11 (Node2@n2_rs_msg_recvd)
#define n3_s1 (Node3@n3_slot_begin)
#define n3_s2 (Node3@n3_ts_msgorigin_rt)
#define n3_s3 (Node3@n3_ts_msgorigin_nrt)
#define n3_s4 (Node3@n3_ts_fw_rt)
#define n3_s5 (Node3@n3_ts_fw_nrt)
#define n3_s6 (Node3@n3_ts_wait_for_ack)
#define n3_s7 (Node3@n3_ts_ack_loss)
#define n3_s8 (Node3@n3_ts_ack_recvd)
#define n3_s9 (Node3@n3_rs)
#define n3_s10 (Node3@n3_rs_msg_loss) 
#define n3_s11 (Node3@n3_rs_msg_recvd)
#define NODE_0 0
#define NODE_1 1
#define NODE_2 2
#define NODE_3 3
#define RECIEVESLOT 1
#define TRANSMITSLOT 2
#define SENSORDATA1 1 
#define SENSORDATA2 2
#define SENSORDATA3 3
#define SENSORDATA4 4
#define SENSORDATA5 5
#define WAITFORACK 1
#define DEFAULT 2
#define MAXCHANNEL 2
#define GROSSCYCLETIME 206
#define TIMESLOT 1
#define LDS0 9
#define LDS1 13
#define LDS2 7
#define LDS3 5
typedef deviceSchedule
{
	
	byte slotno;
	byte channelno;
	byte deviceid;
	byte slottype;
	bool retransmitFlag
	bool msgOriginFlag;
};
mtype={SENSORDATA,ACK};
deviceSchedule ds0[9],ds1[13],ds2[7],ds3[5];
chan shared_channel = [16] of {int,int};
chan tdma_channel[MAXCHANNEL]=[10] of{mtype,byte,byte,byte,byte}
#define set(tmr,value) tmr=value
#define expire(tmr) (tmr<=0)
#define tick(tmr) if ::(tmr>=0)->tmr=tmr-1::else fi
int gltimer,lctimer0,timeslottimer0,lctimer1,timeslottimer1,lctimer2,timeslottimer2;
int lctimer3,timeslottimer3;
#ifdef MESSAGE_COLLISION
int no_of_transmit=0;
#endif
bool ireset0,ireset1,ireset2,ireset3;
byte n0;
proctype timers()
{
do
	::timeout->
	   atomic {
	 	tick(gltimer);
	 	tick(lctimer0);
	 	tick(timeslottimer0);
	 	tick(lctimer1);
	 	tick(timeslottimer1);
	 	tick(lctimer2);
	 	tick(timeslottimer2);
	 	tick(lctimer3);
	 	tick(timeslottimer3);
		}					 	       
 	od;
 }		
proctype Node0(byte node_id)
{
byte i,source,dest,sourceorigin,msg,state,channelno,msgretransmit,msg_recvd,msg_saved,sourceorigin_saved;
int temp1,temp2;
bool retransmit;
begin_tdma:
#ifdef DESIGNERROR
progress0n0_cycle_begin:
#endif	
atomic
{
set(gltimer,GROSSCYCLETIME);
i=0;
ireset0=true;
}
  	do
    ::(i>=LDS0)->
       expire(gltimer);     
        goto begin_tdma;  
    ::(i<LDS0)->
       if
       ::(i==0)->
           atomic
           {
            if
            ::(ireset0 && ireset1 && ireset2 && ireset3)
       			temp1=ds0[i].slotno-1;
       			temp2=temp1*TIMESLOT;
          		set(lctimer0,temp2);
          	fi;	
          	}
       ::else
           atomic
           {
            ireset0=false;
            temp1=ds0[i].slotno-1;
            temp2=ds0[i-1].slotno;
            temp1=temp1-temp2;
       		temp2=temp1*TIMESLOT;      
          	set(lctimer0,temp2);
          	}
       fi;  
       do
       ::     
		expire(lctimer0);
		break;
		od;		
#ifdef DESIGNERROR
progress0n0_slot_begin:
#endif		
n0_slot_begin:
#ifdef MESSAGE_COLLISION
no_of_transmit=0;
#endif
if       
       :: ((ds0[i].slottype==TRANSMITSLOT) && (ds0[i].msgOriginFlag==true) && (ds0[i].retransmitFlag==true))->
        n0_ts_msgorigin_rt:
              		#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif	              		
                 	dest=ds0[i].deviceid;
					channelno=ds0[i].channelno;
              	   	source=node_id;
              	   	sourceorigin=node_id;
              	   	sourceorigin_saved=sourceorigin;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin,msg_saved;
              	   	state=WAITFORACK;
        
       ::else ->skip;       	   	
       fi;
       if       
       :: ((ds0[i].slottype==TRANSMITSLOT) && (ds0[i].msgOriginFlag==true) && (ds0[i].retransmitFlag==false))-> 
n0_ts_msgorigin_nrt:
           			#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif       				
       				if
 				    ::msg=SENSORDATA1;
               		::msg=SENSORDATA2;
               		::msg=SENSORDATA3;
               		::msg=SENSORDATA4;
               		::msg=SENSORDATA5;
               		fi;
               		atomic
               		{ 
               		dest=ds0[i].deviceid;
               		source=node_id;
               		sourceorigin=node_id;
               		sourceorigin_saved=sourceorigin;
               		channelno=ds0[i].channelno;
               		msg_saved=msg;
               		tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin,msg;
               		state=WAITFORACK;
               		}
         ::else->skip;      		
        fi;    
        if       
       :: ((ds0[i].slottype==TRANSMITSLOT) && (ds0[i].msgOriginFlag==false) && (ds0[i].retransmitFlag==true))->
n0_ts_fw_rt:       
       				#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
       				if
               		::(retransmit==true)->
               		atomic
               		{
              	   	dest=ds0[i].deviceid;
              	   	channelno=ds0[i].channelno;
              	   	source=node_id;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
              	   	state=WAITFORACK;
              	   	}
              	   	::else 
              	   	atomic
              	   	{
              	   		set(timeslottimer0,TIMESLOT);
              	   		do
              	   		::
              	   		expire(timeslottimer0);
              	   		break;
              	   		od;
              	   	
              	   	}
                	fi;
        ::else->skip;
        fi;
        if       
       :: ((ds0[i].slottype==TRANSMITSLOT) && (ds0[i].msgOriginFlag==false) && (ds0[i].retransmitFlag==false))->
 n0_ts_fw_nrt:        				
               		#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
              	   	dest=ds0[i].deviceid;
              	   	channelno=ds0[i].channelno;
              	   	source=node_id;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
              	   	state=WAITFORACK;              
        ::else->skip;
        fi;
        if
        ::((ds0[i].slottype==TRANSMITSLOT) && (state==WAITFORACK))
n0_ts_wait_for_ack:        
             set(timeslottimer0,TIMESLOT);
             do
             ::expire(timeslottimer0)->
n0_ts_ack_loss:              
                  retransmit=true;
                  state=DEFAULT;
                  break;
             ::tdma_channel[channelno]? ACK(source,dest,sourceorigin,msg);
n0_ts_ack_recvd:  retransmit=false;
                  state=DEFAULT;
                  break;    
             od;
        ::else->skip;   
        fi;
        if
        ::(ds0[i].slottype==RECIEVESLOT)
n0_rs:   set(timeslottimer0,TIMESLOT);
          channelno=ds0[i].channelno;
          do
             ::expire(timeslottimer0)->
n0_rs_msg_loss: break;
             ::tdma_channel[channelno]? SENSORDATA(source,dest,sourceorigin,msg_recvd);
n0_rs_msg_recvd: msg_saved=msg_recvd;
                sourceorigin_saved=sourceorigin;
                 tdma_channel[channelno] !ACK(dest,source,sourceorigin,msg_recvd);
               	break;     
          od;
       ::else->skip;
        fi; 
        expire(timeslottimer0);
        i=i+1;                    
    od; 
}
proctype Node1(byte node_id)
{
byte i,source,dest,sourceorigin,msg,state,channelno,msgretransmit,msg_saved,msg_recvd,sourceorigin_saved;
int temp1,temp2;
bool retransmit;
begin_tdma:
#ifdef DESIGNERROR
progress1n1_cycle_begin:
#endif	
atomic
{
set(gltimer,GROSSCYCLETIME);
i=0;
ireset1=true;
}
  	do
    ::(i>=LDS1)->
         expire(gltimer);
         goto begin_tdma; 
    ::(i<LDS1)->
       if
       ::(i==0)->
       		if
       		::(ireset0 && ireset1 && ireset2 && ireset3)
       		temp1=ds1[i].slotno-1;
       		temp2=temp1*TIMESLOT;
          	set(lctimer1,temp2);
          	fi;
       ::else
            ireset1=false;
            temp1=ds1[i].slotno-1;
            temp2=ds1[i-1].slotno;
            temp1=temp1-temp2;
       		temp2=temp1*TIMESLOT;      
          	set(lctimer1,temp2);  	
       fi;
       do
       ::       
       expire(lctimer1);
       break;
       od;
       #ifdef DESIGNERROR
progress1n1_slot_begin:
#endif	
n1_slot_begin:
#ifdef MESSAGE_COLLISION
	no_of_transmit=0;
#endif              
       if       
       :: ((ds1[i].slottype==TRANSMITSLOT) && (ds1[i].msgOriginFlag==true) && (ds1[i].retransmitFlag==true))->
n1_ts_msgorigin_rt:	
					#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
					dest=ds1[i].deviceid;
					channelno=ds1[i].channelno;
              	   	source=node_id;
              	   	sourceorigin=node_id;
              	   	sourceorigin_saved=sourceorigin;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin,msg_saved;
              	   	state=WAITFORACK;
       ::else->skip;       	   	
       fi;
       if       
       :: ((ds1[i].slottype==TRANSMITSLOT) && (ds1[i].msgOriginFlag==true) && (ds1[i].retransmitFlag==false))-> 
n1_ts_msgorigin_nrt:       				
       				#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
       				if
               		::msg=SENSORDATA1;
               		::msg=SENSORDATA2;
               		::msg=SENSORDATA3;
               		::msg=SENSORDATA4;
               		::msg=SENSORDATA5;
               		fi;
               		dest=ds1[i].deviceid;
					source=node_id;
               		sourceorigin=node_id;
               		sourceorigin_saved=sourceorigin;
               		channelno=ds1[i].channelno;
               		msg_saved=msg;
               		tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
               		state=WAITFORACK;
        ::else->skip;
        fi;    
        if       
       :: ((ds1[i].slottype==TRANSMITSLOT) && (ds1[i].msgOriginFlag==false) && (ds1[i].retransmitFlag==true))->
n1_ts_fw_rt:
       				#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
       				if
               		::(retransmit==true)->
              	   	dest=ds1[i].deviceid;
              	   	channelno=ds1[i].channelno;
              	   	source=node_id;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
              	   	state=WAITFORACK;
              	   	::else 
              	   		set(timeslottimer1,TIMESLOT);
              	   		do
              	   		::
              	   		expire(timeslottimer1);
              	   		break;
              	   		od;
                	fi;
        ::else->skip;
        fi;
        if       
       	:: ((ds1[i].slottype==TRANSMITSLOT) && (ds1[i].msgOriginFlag==false) && (ds1[i].retransmitFlag==false))->
n1_ts_fw_nrt:       
					#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
					dest=ds1[i].deviceid;
              	   	channelno=ds1[i].channelno;
              	   	source=node_id;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
              	   	state=WAITFORACK;
        ::else->skip;
        fi; 
        if
        ::((ds1[i].slottype==TRANSMITSLOT) && (state==WAITFORACK))
n1_ts_wait_for_ack:        
             set(timeslottimer1,TIMESLOT);
             do
             ::expire(timeslottimer1)->
n1_ts_ack_loss:             
                  retransmit=true;
                  state=DEFAULT;
                  break;
             ::tdma_channel[channelno]? ACK(source,dest,sourceorigin,msg);
n1_ts_ack_recvd:             
                  retransmit=false;
                  state=DEFAULT;
                  break;          
             od;
        ::else->skip;   
        fi;
        if
        ::(ds1[i].slottype==RECIEVESLOT)
n1_rs:  set(timeslottimer1,TIMESLOT);
          channelno=ds1[i].channelno;
          do
             ::expire(timeslottimer1)->
n1_rs_msg_loss:break;
             ::tdma_channel[channelno]? SENSORDATA(source,dest,sourceorigin,msg_recvd);
n1_rs_msg_recvd:
				msg_saved=msg_recvd;
                sourceorigin_saved=sourceorigin;
                 tdma_channel[channelno] !ACK(dest,source,sourceorigin,msg_recvd);
               	break;     
          od;
       ::else->skip;
        fi;
        expire(timeslottimer1);
        i=i+1;         
    od; 
}
proctype Node2(byte node_id)
{
byte i,source,dest,sourceorigin,sourceorigin_saved,msg,msg_saved,state,channelno,msgretransmit,msg_recvd;
int temp1,temp2;
bool retransmit;
begin_tdma:
#ifdef DESIGNERROR
progress2n2_cycle_begin:
#endif
set(gltimer,GROSSCYCLETIME);
i=0;
ireset2=true;
  	do
    ::(i>=LDS2)->
    	 expire(gltimer);
         goto begin_tdma;       
    ::(i<LDS2)->
       if
       ::(i==0)->
       		if
       		::(ireset0 && ireset1 && ireset2 && ireset3)->
       		temp1=ds2[i].slotno-1;
       		temp2=temp1*TIMESLOT;
          	set(lctimer2,temp2);
          	fi;
       ::else
            ireset2=false;
            temp1=ds2[i].slotno-1;
            temp2=ds2[i-1].slotno;
            temp1=temp1-temp2;
       		temp2=temp1*TIMESLOT;      
          	set(lctimer2,temp2);
       fi;
       do
       ::      
       expire(lctimer2);
       break;
       od;
       #ifdef DESIGNERROR
progress2n2_slot_begin:
#endif	    
n2_slot_begin:
       #ifdef MESSAGE_COLLISION
			no_of_transmit=0;
	   #endif          
       if       
       :: ((ds2[i].slottype==TRANSMITSLOT) && (ds2[i].msgOriginFlag==true) && (ds2[i].retransmitFlag==true))->
n2_ts_msgorigin_rt:       
              	   	#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
              	   	dest=ds2[i].deviceid;
              	   	channelno=ds2[i].channelno;
              	   	source=node_id;
              	   	sourceorigin=node_id;
              	   	sourceorigin_saved=sourceorigin;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin,msg_saved;
              	   	state=WAITFORACK;
       ::else->skip;
       fi;
       if       
       :: ((ds2[i].slottype==TRANSMITSLOT) && (ds2[i].msgOriginFlag==true) && (ds2[i].retransmitFlag==false))-> 
n2_ts_msgorigin_nrt:       				
       				#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
       				if
               		::msg=SENSORDATA1;
               		::msg=SENSORDATA2;
               		::msg=SENSORDATA3;
               		::msg=SENSORDATA4;
               		::msg=SENSORDATA5;
               		fi;
               		dest=ds2[i].deviceid;
               		source=node_id;
               		sourceorigin=node_id;
               		sourceorigin_saved=node_id;
               		msg_saved=msg;
               		channelno=ds2[i].channelno;
               		tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin,msg;
               		state=WAITFORACK;
        ::else->skip;
        fi;    
        if       
       :: ((ds2[i].slottype==TRANSMITSLOT) && (ds2[i].msgOriginFlag==false) && (ds2[i].retransmitFlag==true))->
n2_ts_fw_rt:       				
       				#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
       				if
               		::(retransmit==true)->
              	   	dest=ds2[i].deviceid;
              	   	channelno=ds2[i].channelno;
              	   	source=node_id;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
              	   	state=WAITFORACK;
                	fi;
        ::else->skip;
        fi;
        if       
       	:: ((ds2[i].slottype==TRANSMITSLOT) && (ds2[i].msgOriginFlag==false) && (ds2[i].retransmitFlag==false))->
n2_ts_fw_nrt:       
					#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
					dest=ds2[i].deviceid;
              	   	channelno=ds2[i].channelno;
              	   	source=node_id;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
              	   	state=WAITFORACK;
              	   	/*}*/
        ::else->skip;
        fi;   
        if
        ::((ds2[i].slottype==TRANSMITSLOT) && (state==WAITFORACK))
n2_ts_wait_for_ack:                	
             set(timeslottimer2,TIMESLOT);
             do
             ::expire(timeslottimer2)->
n2_ts_ack_loss:                  
                  retransmit=true;
                  state=DEFAULT;
                  break;
             ::tdma_channel[channelno]? ACK(source,dest,sourceorigin,msg);
n2_ts_ack_recvd:             
                  retransmit=false;
                  state=DEFAULT;
                  break;          
             od;
        ::else->skip;   
        fi;
        if
        ::(ds2[i].slottype==RECIEVESLOT)
n2_rs:    set(timeslottimer2,TIMESLOT);
          channelno=ds2[i].channelno;
          do
             ::expire(timeslottimer2)->
n2_rs_msg_loss:             
               break;
             ::tdma_channel[channelno]? SENSORDATA(source,dest,sourceorigin,msg_recvd);
n2_rs_msg_recvd:             
               msg_saved=msg_recvd;
                sourceorigin_saved=sourceorigin;
                 tdma_channel[channelno] !ACK(dest,source,sourceorigin,msg);
               	break;          
          od;
       ::else->skip;
        fi;
        expire(timeslottimer2);
        i=i+1;  
    od; 
}
proctype Node3(byte node_id)
{
byte i,source,dest,sourceorigin,sourceorigin_saved,msg,msg_saved,msg_recvd,state,channelno,msgretransmit;
int temp1,temp2;
bool retransmit;
begin_tdma:
#ifdef DESIGNERROR
progress1n1_cycle_begin:
#endif
atomic
{
set(gltimer,GROSSCYCLETIME);
i=0;
ireset3=true;
}
  	do
    ::(i>=LDS3)->
         expire(gltimer);
         goto begin_tdma;         
    ::(i<LDS3)->
       if
       ::(i==0)->
       		if
       		::(ireset0 && ireset1 && ireset2 && ireset3 )
       		temp1=ds3[i].slotno-1;
       		temp2=temp1*TIMESLOT;
          	set(lctimer3,temp2);
          	fi;   	
       ::else
            ireset3=false;
            temp1=ds3[i].slotno-1;
            temp2=ds3[i-1].slotno;
            temp1=temp1-temp2;
       		temp2=temp1*TIMESLOT;      
          	set(lctimer3,temp2);  	
       fi;
       do
       ::       
       expire(lctimer3);
       break;
       od;
#ifdef DESIGNERROR
progress3n3_slot_begin:
#endif	   
n3_slot_begin:
       #ifdef MESSAGE_COLLISION
			no_of_transmit=0;
	   #endif       
       if       
       :: ((ds3[i].slottype==TRANSMITSLOT) && (ds3[i].msgOriginFlag==true) && (ds3[i].retransmitFlag==true))->
n3_ts_msgorigin_rt:       
              	   	#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
              	   	dest=ds3[i].deviceid;
              	   	channelno=ds3[i].channelno;
              	   	source=node_id;
              	   	sourceorigin=node_id;
              	   	sourceorigin_saved=sourceorigin;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin,msg_saved;
              	   	state=WAITFORACK;
       ::else->skip;
       fi;
       if       
       :: ((ds3[i].slottype==TRANSMITSLOT) && (ds3[i].msgOriginFlag==true) && (ds3[i].retransmitFlag==false))->
n3_ts_msgorigin_nrt:        
       				#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
       				if
               		::msg=SENSORDATA1;
               		::msg=SENSORDATA2;
               		::msg=SENSORDATA3;
               		::msg=SENSORDATA4;
               		::msg=SENSORDATA5;
               		fi;
               		dest=ds3[i].deviceid;
               		source=node_id;
               		sourceorigin=node_id;
               		sourceorigin_saved=sourceorigin;
               		channelno=ds3[i].channelno;
               		msg_saved=msg;
               		tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin,msg;
               		state=WAITFORACK;
        ::else->skip;
        fi;    
        if       
       :: ((ds3[i].slottype==TRANSMITSLOT) && (ds3[i].msgOriginFlag==false) && (ds3[i].retransmitFlag==true))->
n3_ts_fw_rt:
       				#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
       				if
               		::(retransmit==true)->
              	   	dest=ds3[i].deviceid;
              	   	channelno=ds3[i].channelno;
              	   	source=node_id;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
              	   	state=WAITFORACK;
                	fi;
        ::else->skip;
        fi;
        if       
       	:: ((ds3[i].slottype==TRANSMITSLOT) && (ds3[i].msgOriginFlag==false) && (ds3[i].retransmitFlag==false))->
n3_ts_fw_nrt:       				
              	   	#ifdef MESSAGE_COLLISION
						no_of_transmit++;
					#endif
              	   	dest=ds3[i].deviceid;
              	   	channelno=ds3[i].channelno;
              	   	source=node_id;
              	   	tdma_channel[channelno]! SENSORDATA,source,dest,sourceorigin_saved,msg_saved;
              	   	state=WAITFORACK;            
        ::else->skip;
        fi;
        if
        ::((ds3[i].slottype==TRANSMITSLOT) && (state==WAITFORACK))
n3_ts_wait_for_ack:                	           
             set(timeslottimer3,TIMESLOT);
             do
             ::expire(timeslottimer3)->
n3_ts_ack_loss:             
                  retransmit=true;
                  state=DEFAULT;
                  break;
             ::tdma_channel[channelno]? ACK(source,dest,sourceorigin,msg);
n3_ts_ack_recvd:             
                  retransmit=false;
                  state=DEFAULT;
                  break;     
             od;
        ::else->skip;
        fi;
        if
        ::(ds3[i].slottype==RECIEVESLOT)
n3_rs:     
          set(timeslottimer3,TIMESLOT);
          channelno=ds3[i].channelno;
          do
             ::expire(timeslottimer3)->
n3_rs_msg_loss:             
               break;
             ::tdma_channel[channelno]? SENSORDATA(source,dest,sourceorigin,msg_recvd);
n3_rs_msg_recvd:             
               msg_saved=msg_recvd;
               sourceorigin_saved=sourceorigin;
               tdma_channel[channelno] !ACK(dest,source,sourceorigin,msg_recvd);
               break;     
          od;
       ::else->skip;
        fi;
        expire(timeslottimer3);
        i=i+1;        	   		   	   	
    od; 
}
#ifdef LOSSY
proctype Daemon()
{
	
	do
	:: tdma_channel[1]? ACK(_,_,_,_);
	:: tdma_channel[1]? SENSORDATA(_,_,_,_);
	od;
}
#endif
init {
	atomic
	{
		ds0[0].slotno=2;
		ds0[0].channelno=1;
		ds0[0].deviceid=1;
		ds0[0].slottype=RECIEVESLOT;
		ds0[0].retransmitFlag=false;
		ds0[0].msgOriginFlag=false;
		ds0[1].slotno=4;
		ds0[1].channelno=1;
		ds0[1].deviceid=2;
		ds0[1].slottype=RECIEVESLOT;
		ds0[1].retransmitFlag=false;
		ds0[1].msgOriginFlag=false;
		ds0[2].slotno=27;
		ds0[2].channelno=1;
		ds0[2].deviceid=1;
		ds0[2].slottype=RECIEVESLOT;
		ds0[2].retransmitFlag=false;
		ds0[2].msgOriginFlag=false;
		ds0[3].slotno=52;
		ds0[3].channelno=1;
		ds0[3].deviceid=1;
		ds0[3].slottype=RECIEVESLOT;
		ds0[3].retransmitFlag=false;
		ds0[3].msgOriginFlag=false;
		ds0[4].slotno=77;
		ds0[4].channelno=1;
		ds0[4].deviceid=1;
		ds0[4].slottype=RECIEVESLOT;
		ds0[4].retransmitFlag=false;
		ds0[4].msgOriginFlag=false;
		ds0[5].slotno=102;
		ds0[5].channelno=1;
		ds0[5].deviceid=1;
		ds0[5].slottype=RECIEVESLOT;
		ds0[5].retransmitFlag=false;
		ds0[5].msgOriginFlag=false;
		ds0[6].slotno=104;
		ds0[6].channelno=1;
		ds0[6].deviceid=2;
		ds0[6].slottype=RECIEVESLOT;
		ds0[6].retransmitFlag=false;
		ds0[6].msgOriginFlag=false;
		ds0[7].slotno=204;
		ds0[7].channelno=1;
		ds0[7].deviceid=2;
		ds0[7].slottype=RECIEVESLOT;
		ds0[7].retransmitFlag=false;
		ds0[7].msgOriginFlag=false;
		ds0[8].slotno=205;
		ds0[8].channelno=1;
		ds0[8].deviceid=2;
		ds0[8].slottype=RECIEVESLOT;
		ds0[8].retransmitFlag=false;
		ds0[8].msgOriginFlag=false;
		ds1[0].slotno=1;
		ds1[0].channelno=1;
		ds1[0].deviceid=3;
		ds1[0].slottype=RECIEVESLOT;
		ds1[0].retransmitFlag=false;
		ds1[0].msgOriginFlag=false;
		ds1[1].slotno=2;
		ds1[1].channelno=1;
		ds1[1].deviceid=0;
		ds1[1].slottype=TRANSMITSLOT;
		ds1[1].retransmitFlag=false;
		ds1[1].msgOriginFlag=false;
		ds1[2].slotno=3;
		ds1[2].channelno=1;
		ds1[2].deviceid=2;
		ds1[2].slottype=TRANSMITSLOT;
		ds1[2].retransmitFlag=false;
		ds1[2].msgOriginFlag=false;
		ds1[3].slotno=26;
		ds1[3].channelno=1;
		ds1[3].deviceid=3;
		ds1[3].slottype=RECIEVESLOT;
		ds1[3].retransmitFlag=false;
		ds1[3].msgOriginFlag=false;
		ds1[4].slotno=27;
		ds1[4].channelno=1;
		ds1[4].deviceid=0;
		ds1[4].slottype=TRANSMITSLOT;
		ds1[4].retransmitFlag=false;
		ds1[4].msgOriginFlag=false;
		ds1[5].slotno=51;
		ds1[5].channelno=1;
		ds1[5].deviceid=3;
		ds1[5].slottype=RECIEVESLOT;
		ds1[5].retransmitFlag=false;
		ds1[5].msgOriginFlag=false;
		ds1[6].slotno=52;
		ds1[6].channelno=1;
		ds1[6].deviceid=0;
		ds1[6].slottype=TRANSMITSLOT;
		ds1[6].retransmitFlag=false;
		ds1[6].msgOriginFlag=false;
		ds1[7].slotno=76;
		ds1[7].channelno=1;
		ds1[7].deviceid=3;
		ds1[7].slottype=RECIEVESLOT;
		ds1[7].retransmitFlag=false;
		ds1[7].msgOriginFlag=false;
		ds1[8].slotno=77;
		ds1[8].channelno=1;
		ds1[8].deviceid=0;
		ds1[8].slottype=TRANSMITSLOT;
		ds1[8].retransmitFlag=false;
		ds1[8].msgOriginFlag=false;
		ds1[9].slotno=101;
		ds1[9].channelno=1;
		ds1[9].deviceid=3;
		ds1[9].slottype=RECIEVESLOT;
		ds1[9].retransmitFlag=false;
		ds1[9].msgOriginFlag=false;
		ds1[10].slotno=102;
		ds1[10].channelno=1;
		ds1[10].deviceid=0;
		ds1[10].slottype=TRANSMITSLOT;
		ds1[10].retransmitFlag=false;
		ds1[10].msgOriginFlag=false;
		ds1[11].slotno=103;
		ds1[11].channelno=1;
		ds1[11].deviceid=2;
		ds1[11].slottype=TRANSMITSLOT;
		ds1[11].retransmitFlag=false;
		ds1[11].msgOriginFlag=true;
		ds1[12].slotno=203;
		ds1[12].channelno=1;
		ds1[12].deviceid=2;
		ds1[12].slottype=TRANSMITSLOT;
		ds1[12].retransmitFlag=false;
		ds1[12].msgOriginFlag=true;
		ds2[0].slotno=3;
		ds2[0].channelno=1;
		ds2[0].deviceid=1;
		ds2[0].slottype=RECIEVESLOT;
		ds2[0].retransmitFlag=false;
		ds2[0].msgOriginFlag=false;
		ds2[1].slotno=4;
		ds2[1].channelno=1;
		ds2[1].deviceid=0;
		ds2[1].slottype=TRANSMITSLOT;
		ds2[1].retransmitFlag=false;
		ds2[1].msgOriginFlag=false;
		ds2[2].slotno=103;
		ds2[2].channelno=1;
		ds2[2].deviceid=1;
		ds2[2].slottype=RECIEVESLOT;
		ds2[2].retransmitFlag=false;
		ds2[2].msgOriginFlag=false;
		ds2[3].slotno=104;
		ds2[3].channelno=1;
		ds2[3].deviceid=0;
		ds2[3].slottype=TRANSMITSLOT;
		ds2[3].retransmitFlag=false;
		ds2[3].msgOriginFlag=false;
		ds2[4].slotno=203;
		ds2[4].channelno=1;
		ds2[4].deviceid=1;
		ds2[4].slottype=RECIEVESLOT;
		ds2[4].retransmitFlag=false;
		ds2[4].msgOriginFlag=false;
		ds2[5].slotno=204;
		ds2[5].channelno=1;
		ds2[5].deviceid=0;
		ds2[5].slottype=TRANSMITSLOT;
		ds2[5].retransmitFlag=false;
		ds2[5].msgOriginFlag=false;
		ds2[6].slotno=205;
		ds2[6].channelno=1;
		ds2[6].deviceid=0;
		ds2[6].slottype=TRANSMITSLOT;
		ds2[6].retransmitFlag=false;
		ds2[6].msgOriginFlag=true;
		ds3[0].slotno=1;
		ds3[0].channelno=1;
		ds3[0].deviceid=1;
		ds3[0].slottype=TRANSMITSLOT;
		ds3[0].msgOriginFlag=true;
		ds3[1].slotno=26;
		ds3[1].channelno=1;
		ds3[1].deviceid=1;
		ds3[1].slottype=TRANSMITSLOT;
		ds3[1].retransmitFlag=false;
		ds3[1].msgOriginFlag=true;
		ds3[2].slotno=51;
		ds3[2].channelno=1;
		ds3[2].deviceid=1;
		ds3[2].slottype=TRANSMITSLOT;
		ds3[2].retransmitFlag=false;
		ds3[2].msgOriginFlag=true;
		ds3[3].slotno=76;
		ds3[3].channelno=1;
		ds3[3].deviceid=1;
		ds3[3].slottype=TRANSMITSLOT;
		ds3[3].retransmitFlag=false;
		ds3[3].msgOriginFlag=true;
		ds3[4].slotno=101;
		ds3[4].channelno=1;
		ds3[4].deviceid=1;
		ds3[4].slottype=TRANSMITSLOT;
		ds3[4].retransmitFlag=false;
		ds3[4].msgOriginFlag=true;
		ireset0=false;
		ireset1=false;
		ireset2=false;
		ireset3=false;
		#ifdef LOSSY
		    run Daemon();
		#endif    
		    run Node0(0);
			run Node1(1);
			run Node2(2);
			run Node3(3);
	    	run timers();	
	
	}			
}
#ifdef NONLOSSY
#ifdef P0 /*Reachable State */
never
{
do
:: n0_s1->break;
:: true;
od;
}
#endif
#ifdef P1 /* Unreachable State */
never  
{
do
::n0_s1->break;
::true;
od;
do
::n0_s2->break;
::true;
od;
}
#endif
#ifdef P2 /*Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s3->break;
::true;
od;
}
#endif
#ifdef P3 /*Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s4->break;
::true;
od;
}
#endif
#ifdef P4 /*Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s5->break;
::true;
od;
}
#endif
#ifdef P5 /*Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s6->break;
::true;
od;
}
#endif
#ifdef P6 /*Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s7->break;
::true;
od;
}
#endif
#ifdef P7 /*Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s8->break;
::true;
od;
}
#endif
#ifdef P8
never   /* Reachable State */
{
do
::n0_s1->break;
::true;
od;
do
::n0_s9->break;
::true;
od;
}
#endif
#ifdef P9 /*Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s10->break;
::true;
od;
}
#endif
#ifdef P10
never /* Reachable State */
{
do
::n0_s1->break;
::true;
od;
do
::n0_s11->break;
::true;
od;
}
#endif

#ifdef P11 /*Reachable State */
never
{
do
:: n1_s1->break;
:: true;
od;
}
#endif
#ifdef P12 /* Unreachable State */
never  
{
do
::n1_s1->break;
::true;
od;
do
::n1_s2->break;
::true;
od;
}
#endif
#ifdef P13 /* Reachable State */ 
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s3->break;
::true;
od;
}
#endif
#ifdef P14 /* Unreachable State */ 
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s4->break;
::true;
od;
}
#endif
#ifdef P15 /* Reachable State */
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s5->break;
::true;
od;
}
#endif
#ifdef P16 /* Reachable State */
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s6->break;
::true;
od;
}
#endif
#ifdef P17 /* Unreachable State */
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s7->break;
::true;
od;
}
#endif
#ifdef P18 /* Reachable State */ 
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s8->break;
::true;
od;
}
#endif
#ifdef P19 /* Reachable State */
never   
{
do
::n1_s1->break;
::true;
od;
do
::n1_s9->break;
::true;
od;
}
#endif
#ifdef P20 /* Unreachable State */
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s10->break;
::true;
od;
}
#endif
#ifdef P21 /* Reachable State */ 
never 
{
do
::n1_s1->break;
::true;
od;
do
::n1_s11->break;
::true;
od;
}
#endif
#ifdef P22 /* Reachable State */ 
never
{
do
:: n2_s1->break;
:: true;
od;
}
#endif
#ifdef P23 /* Unreachable State */
never  
{
do
::n2_s1->break;
::true;
od;
do
::n2_s2->break;
::true;
od;
}
#endif
#ifdef P24 /* Reachable State */ 
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s3->break;
::true;
od;
}
#endif
#ifdef P25  /* Unreachable State */
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s4->break;
::true;
od;
}
#endif
#ifdef P26 /* Reachable State */
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s5->break;
::true;
od;
}
#endif
#ifdef P27 /* Reachable State */
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s6->break;
::true;
od;
}
#endif
#ifdef P28 /* Unreachable State */
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s7->break;
::true;
od;
}
#endif
#ifdef P29 /* Reachable State */   
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s8->break;
::true;
od;
}
#endif
#ifdef P30 /* Reachable State */
never   
{
do
::n2_s1->break;
::true;
od;
do
::n2_s9->break;
::true;
od;
}
#endif
#ifdef P31 /* Unreachable State */
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s10->break;
::true;
od;
}
#endif
#ifdef P32  /* Reachable State */
never 
{
do
::n2_s1->break;
::true;
od;
do
::n2_s11->break;
::true;
od;
}
#endif
#ifdef P33  /* Reachable State */
never
{
do
:: n3_s1->break;
:: true;
od;
}
#endif
#ifdef P34 /* Unreachable State */
never  
{
do
::n3_s1->break;
::true;
od;
do
::n3_s2->break;
::true;
od;
}
#endif
#ifdef P35 /* Reachable State */ 
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s3->break;
::true;
od;
}
#endif
#ifdef P36  /* Unreachable State */
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s4->break;
::true;
od;
}
#endif
#ifdef P37 /* Unreachable State */
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s5->break;
::true;
od;
}
#endif
#ifdef P38 /* Reachable State */
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s6->break;
::true;
od;
}
#endif
#ifdef P39 /* Unreachable State */
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s7->break;
::true;
od;
}
#endif
#ifdef P40    /* Reachable State */
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s8->break;
::true;
od;
}
#endif
#ifdef P41 /* Unreachable State */
never   
{
do
::n3_s1->break;
::true;
od;
do
::n3_s9->break;
::true;
od;
}
#endif
#ifdef P42 /* Unreachable State */
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s10->break;
::true;
od;
}
#endif
#ifdef P43  /* Unreachable State */
never 
{
do
::n3_s1->break;
::true;
od;
do
::n3_s11->break;
::true;
od;
}
#endif
#endif
#ifdef LOSSY
#ifdef P0 /*Reachable State */
never
{
do
:: n0_s1->break;
:: true;
od;
}
#endif
#ifdef P1    /*Unreachable State */
never  
{
do
::n0_s1->break;
::true;
od;
do
::n0_s2->break;
::true;
od;
}
#endif
#ifdef P2 /* Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s3->break;
::true;
od;
}
#endif
#ifdef P3 /* Unreachable State */
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s4->break;
::true;
od;
}
#endif
#ifdef P4 
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s5->break;
::true;
od;
}
#endif
#ifdef P5 
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s6->break;
::true;
od;
}
#endif
#ifdef P6 
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s7->break;
::true;
od;
}
#endif
#ifdef P7 
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s8->break;
::true;
od;
}
#endif
#ifdef P8
never   
{
do
::n0_s1->break;
::true;
od;
do
::n0_s9->break;
::true;
od;
}
#endif
#ifdef P9 
never
{
do
::n0_s1->break;
::true;
od;
do
::n0_s10->break;
::true;
od;
}
#endif
#ifdef P10
never 
{
do
::n0_s1->break;
::true;
od;
do
::n0_s11->break;
::true;
od;
}
#endif

#ifdef P11 
never
{
do
:: n1_s1->break;
:: true;
od;
}
#endif
#ifdef P12 
never  
{
do
::n1_s1->break;
::true;
od;
do
::n1_s2->break;
::true;
od;
}
#endif
#ifdef P13  
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s3->break;
::true;
od;
}
#endif
#ifdef P14  
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s4->break;
::true;
od;
}
#endif
#ifdef P15 
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s5->break;
::true;
od;
}
#endif
#ifdef P16 
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s6->break;
::true;
od;
}
#endif
#ifdef P17 
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s7->break;
::true;
od;
}
#endif
#ifdef P18  
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s8->break;
::true;
od;
}
#endif
#ifdef P19 
never   
{
do
::n1_s1->break;
::true;
od;
do
::n1_s9->break;
::true;
od;
}
#endif
#ifdef P20 
never
{
do
::n1_s1->break;
::true;
od;
do
::n1_s10->break;
::true;
od;
}
#endif
#ifdef P21  
never 
{
do
::n1_s1->break;
::true;
od;
do
::n1_s11->break;
::true;
od;
}
#endif
#ifdef P22  
never
{
do
:: n2_s1->break;
:: true;
od;
}
#endif
#ifdef P23 
never  
{
do
::n2_s1->break;
::true;
od;
do
::n2_s2->break;
::true;
od;
}
#endif
#ifdef P24  
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s3->break;
::true;
od;
}
#endif
#ifdef P25  
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s4->break;
::true;
od;
}
#endif
#ifdef P26 
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s5->break;
::true;
od;
}
#endif
#ifdef P27 
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s6->break;
::true;
od;
}
#endif
#ifdef P28 
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s7->break;
::true;
od;
}
#endif
#ifdef P29    
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s8->break;
::true;
od;
}
#endif
#ifdef P30 
never   
{
do
::n2_s1->break;
::true;
od;
do
::n2_s9->break;
::true;
od;
}
#endif
#ifdef P31 
never
{
do
::n2_s1->break;
::true;
od;
do
::n2_s10->break;
::true;
od;
}
#endif
#ifdef P32  
never 
{
do
::n2_s1->break;
::true;
od;
do
::n2_s11->break;
::true;
od;
}
#endif
#ifdef P33  
never
{
do
:: n3_s1->break;
:: true;
od;
}
#endif
#ifdef P34 
never  
{
do
::n3_s1->break;
::true;
od;
do
::n3_s2->break;
::true;
od;
}
#endif
#ifdef P35  
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s3->break;
::true;
od;
}
#endif
#ifdef P36  
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s4->break;
::true;
od;
}
#endif
#ifdef P37 
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s5->break;
::true;
od;
}
#endif
#ifdef P38 
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s6->break;
::true;
od;
}
#endif
#ifdef P39 
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s7->break;
::true;
od;
}
#endif
#ifdef P40    
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s8->break;
::true;
od;
}
#endif
#ifdef P41 
never   
{
do
::n3_s1->break;
::true;
od;
do
::n3_s9->break;
::true;
od;
}
#endif
#ifdef P42 
never
{
do
::n3_s1->break;
::true;
od;
do
::n3_s10->break;
::true;
od;
}
#endif
#ifdef P43  
never 
{
do
::n3_s1->break;
::true;
od;
do
::n3_s11->break;
::true;
od;
}
#endif
#endif
#ifdef MESSAGE_COLLISION
never
{
RPT:
do
::no_of_transmit>1->break;
::true;
od;
}
#endif