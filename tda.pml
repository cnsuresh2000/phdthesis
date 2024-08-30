#define LOSSY 101  
#define VERIFICATION 1
#define NODATA 1
#define MAXNODE 5
#define MAXCHANNEL 5
#define MAXITERATION 5
#define TDP 640
#define TRP 640
#define TG 300
#define TFRAME 12580
#define TFRAME1 13
#define RETRY_PING_COUNT 3    
mtype={PING,TDI,REQ,DATA};
chan tda_channel[MAXCHANNEL]=[10] of{mtype,byte,byte,int};
int timer[5],slottimer,ping_packet_timer;
byte pid0,pid1,pid2,pid3,pid4;
#define set(tmr,value) tmr=value
#define expire(tmr) (tmr<=0)
#define tick(tmr) if ::(tmr>=0)->tmr=tmr-1::else fi
inline tpSelect2()
{
	if
	:: tp=5160;
	:: tp=5150;
	:: tp=5140;
	:: tp=5130;
	:: tp=5120;
	:: tp=5110;
	:: tp=5100;
	:: tp=5090;
	:: tp=5080;
	:: tp=5070;
	:: tp=5060;
	:: tp=5050;
	:: tp=5040;
	:: tp=5030;
	:: tp=5020;
	:: tp=5010;
	:: tp=5000;
	:: tp=4990;
	:: tp=4980;
	:: tp=4970;
	:: tp=4960;
	:: tp=4950;
	:: tp=4940;
	:: tp=4930;
	:: tp=4920;
	:: tp=4910;
	:: tp=4900;
	:: tp=4890;
	:: tp=4880;
	:: tp=4870;
	:: tp=4860;
	fi;	
}
proctype timers()
{
do
	::timeout->
	   atomic {
	    tick(timer[0]);
	 	tick(timer[1]);
	 	tick(timer[2]);
	 	tick(timer[3]);
	 	tick(timer[4]);
	 	tick(slottimer);
	 	tick(ping_packet_timer);
		}					 	       
 	od;
 }	
proctype G(byte node_id)
{
	byte i=1;
	int Tp[MAXNODE],Ttx[MAXNODE],Tdp[MAXNODE],Tg[MAXNODE],
    Tpdiff,tp,err;
	byte source,dest;
	int count;
	int msg1;
	tpSelect2();	
/*atomic
	{*/
	
	do
	:: (i< MAXNODE)->
	count=RETRY_PING_COUNT;
	PING_STATE:	
	   tda_channel[i]! PING,node_id,i,NODATA;
	   set(ping_packet_timer,1);	    
	   if
	   ::tda_channel[node_id]? PING(source,dest,msg1)->	   
	   	 Tp[i]=tp;
	   	 Tdp[i]=TDP;
	   	 Tg[i]=TG;
	   :: expire(ping_packet_timer)->
	       count=count-1;
	       if
	       ::(count>=0)-> goto PING_STATE;
	       :: else->skip;
	       fi;
	      if ::(i<MAXNODE-1)
	      	i=i+1;goto PING_STATE;
	      :: else->skip;		
	      fi;		 	 
	   fi;	   
	     i=i+1;          
	:: (i>=MAXNODE)->	
		break;	
	od;
	/*}*/
progress_rpt:
TRANSMIT_COMPUTE:
	atomic
	{
		i=1;
		Ttx[i]=0;
		i=i+1;
		do
		:: (i< MAXNODE)->		
		    if
		    ::(Tp[i]-Tp[i-1]<=0)
		       Tpdiff=0;
		     :: else->
		        Tpdiff=Tp[i]-Tp[i-1];
		      fi;    
	   		Ttx[i]=Ttx[i-1]+Tdp[i-1]+Tg[i-1]
            -(2*Tpdiff);	
	    	i=i+1;   
		:: (i>=MAXNODE)->
			break;
		od;
	}
TTX_STATE:
	/*atomic
	{*/
		i=1;
	do
	:: (i< MAXNODE)->
	   tda_channel[i]! TDI,node_id,i,Ttx[i]; 	   
	    i=i+1;   
	:: (i>=MAXNODE)->
		break;
	od;
	/*}*/
progress_rpt2:
REQUEST_STATE:		
	atomic
	{
		i=1;	
		do
		:: (i< MAXNODE)->
	   	tda_channel[i]! REQ,node_id,i,Tp[i];   	 
	    i=i+1;   
		:: (i>=MAXNODE)->
		break;
		od;
	#ifdef VERIFICATION	
		set(slottimer,TFRAME*(MAXNODE-1));
	#else
		set(slottimer,TFRAME1*(MAXNODE-1));
	#endif	
	do
	::tda_channel[node_id]? DATA(source,dest,msg1)->
	     if
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=160;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   fi;
	  	if
	  	::(err> TG/2)->
	  	   expire(slottimer);
	  	   i=1;
	  	   tpSelect2();
	  	   do
	  	   ::(i< MAXNODE)->
	  	      Tp[i]=tp;
	  	      i=i+1;
	  	    :: (i>=MAXNODE)->
	  	        break;
	  	   od;
	  	   goto progress_rpt;
	  	 :: else->skip;   
	  	fi;
	 ::expire(slottimer)-> 	
	   goto progress_rpt2;	 
	od;	
	}
}


proctype N(byte node_id)
{
	int tp,ttx,msg1,msg2;
	byte i=0;
	byte source,dest;
	bool multipath=false;
	      
	do
	::tda_channel[node_id]? PING(source,dest,msg1);
PING_ACK_STATE:	    
	 		tda_channel[i]! PING(dest,source,
                                     NODATA);
	:: tda_channel[node_id]? TDI(source,dest,msg1);
UPDATE_TTX_STATE:	 
	   ttx=msg1;	
	:: tda_channel[node_id]? REQ(source,
                                      dest,msg1);
REQUEST_PROCESS_STATE:	
	   tp=msg1;
	   if
	   :: msg2=1234;
	   :: msg2=1231;
	   :: msg2=1235;
	   :: msg2=1232;
	   :: msg2=1233;
	   fi;
	   #ifdef VERIFICATION
	   	set(timer[node_id],(TRP+ttx+tp+tp));
	   #else
	    set(timer[node_id],(TRP+ttx+tp+tp)/1000);
	   #endif  	
	   if
	   ::(expire(timer[node_id]))->
DATA_TRANSMIT_STATE:	   
	   	tda_channel[source]! DATA(dest,source,msg2);
	   fi		   
	 od;	
	 	/*multipath=false;
	 fi;*/ 
}
proctype Daemon()
{
	do
	/*:: tda_channel[0]? PING(_,_,_);
	PING_LS0:skip;*/
	/*:: tda_channel[1]? PING(_,_,_);
	PING_LS1:skip;*/
	/*:: tda_channel[2]? PING(_,_,_);
	PING_LS2:skip;*/
	/*:: tda_channel[3]? PING(_,_,_);
	PING_LS3:skip;*/
	/*:: tda_channel[4]? PING(_,_,_);
	PING_LS4:skip;*/
	/*:: tda_channel[1]? TDI(_,_,_);
	TTX_LS1:skip;*/
	/*:: tda_channel[2]? TDI(_,_,_);
	TTX_LS2:skip;*/ 
	/*:: tda_channel[3]? TDI(_,_,_);
	TTX_LS3:skip;*/
	/*:: tda_channel[4]? TDI(_,_,_);
	TTX_LS4:skip;*/
	/*:: tda_channel[1]? REQ(_,_,_);
	REQ_LS1:skip;*/
	/*:: tda_channel[2]? REQ(_,_,_);
	REQ_LS2:skip;*/
	/*:: tda_channel[3]? REQ(_,_,_);
	REQ_LS3:skip;*/
	:: tda_channel[4]? REQ(_,_,_);
	REQ_LS4:skip;
	/*:: tda_channel[0]? DATA(_,_,_);
	DATA_LS0:skip;*/
	od;
}
init {
atomic
{
	timer[0]=-1;
	timer[1]=-1;
	timer[2]=-1;
	timer[3]=-1;
	timer[4]=-1;
	pid0=run G(0);
	pid1=run N(1);
	pid2=run N(2);
	pid3=run N(3);
	pid4=run N(4);
	run timers();
	#ifdef LOSSY
		run Daemon();
	#endif
	
}	
}
/* Property 1 */
/* Never claim for reachability to PING_STATE in Gateway when 
PING packet to N4 is lost */
#ifdef P1
never
{
do
:: Daemon@PING_LS4->break;
:: true;
od;
acceptall:do
::!(G[pid0]@PING_STATE);
od;       
}
#endif
/*Property 2*/
/* Never claim for reachability to TRANSMIT_COMPUTE in Gateway when 
PING packet to N4 is lost */
#ifdef P2
never
{
do 
:: Daemon@PING_LS4->break;
:: true;
od;
acceptall:do
::!(G[pid0]@TRANSMIT_COMPUTE);
od;       
}
#endif
/*Property 3*/
/* Never claim for reachability to TTX_STATE in Gateway when 
PING packet to N4 is lost */
#ifdef P3
never
{
do
:: Daemon@PING_LS4->break;
:: true;
od;
acceptall:do
::!(G[pid0]@TTX_STATE);
od;       
}
#endif
/* Property 4*/
/* Never claim for reachability to REQUEST_STATE in Gateway when 
PING packet to N4 is lost */
#ifdef P4
never
{
do
:: Daemon@PING_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@REQUEST_STATE);
od;       
}
#endif
/*Property 5 */
/* Never claim for reachability to PING_STATE in Gateway when 
TDI packet to N4 is lost */
#ifdef P5
never
{
do
:: Daemon@TTX_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@PING_STATE);
od;       
}
#endif
/*Property 6 */
/* Never claim for reachability to TRANSMIT_COMPUTE in Gateway when 
TDI packet to N4 is lost */
#ifdef P6
never
{
do
:: Daemon@TTX_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@TRANSMIT_COMPUTE);
od;       
}
#endif
/* Property 7 */
/* Never claim for reachability to TTX_STATE in Gateway when 
TDI packet to N4 is lost */
#ifdef P7
never
{
do
:: Daemon@TTX_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@TTX_STATE);
od;       
}
#endif
/* Property 8 */
/* Never claim for reachability to REQUEST_STATE in Gateway when 
TDI packet to N4 is lost */
#ifdef P8
never
{
do
:: Daemon@TTX_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@REQUEST_STATE);
od;       
}
#endif
/* Property 9 */
/* Never claim for reachability to PING_STATE in Gateway when 
REQ packet to N4 is lost */
#ifdef P9
never
{
do
:: Daemon@REQ_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@PING_STATE);
od;       
}
#endif
/* Property 10 */
/* Never claim for reachability to TRANSMIT_COMPUTE in Gateway when 
REQ packet to N4 is lost */
#ifdef P10
never
{
do
:: Daemon@REQ_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@TRANSMIT_COMPUTE);
od;       
}
#endif
/* Property 11 */
/* Never claim for reachability to TTX_STATE in Gateway when 
REQ packet to N4 is lost */
#ifdef P11
never
{
do
:: Daemon@REQ_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@TTX_STATE);
od;       
}
#endif
/* Property 12 */
/* Never claim for reachability to REQUEST_STATE in Gateway when 
REQ packet to N4 is lost */
#ifdef P!@
never
{
do
:: Daemon@REQ_LS4->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@REQUEST_STATE);
od;       
}
#endif
/* Property 13 */
/* Never claim for reachability to PING_STATE in Gateway when 
DATA packet to N0 is lost */
#ifdef P13
never
{
do
:: Daemon@DATA_LS0->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@PING_STATE);
od;       
}
#endif
/* Property 14 */
/* Never claim for reachability to TRANSMIT_COMPUTE in Gateway when 
DATA packet to N0 is lost */
#ifdef P14
never
{
do
:: Daemon@DATA_LS0->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@TRANSMIT_COMPUTE);
od;       
}
#endif
/* Property 15 */
/* Never claim for reachability to TTX_STATE in Gateway when 
DATA packet to N0 is lost */
#ifdef P15
never
{
do
:: Daemon@DATA_LS0->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@TTX_STATE);
od;       
}
#endif
/* Property 16 */
/* Never claim for reachability to REQUEST_STATE in Gateway when 
DATA packet to N0 is lost */
#ifdef P16
never
{
do
:: Daemon@DATA_LS0->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@REQUEST_STATE);
od;       
}
#endif
/* Property 17 */
/* Never claim for reachability to PING_STATE in 
Gateway when PING packet to N0 is lost */
#ifdef P17
never
{
do
:: Daemon@PING_LS0->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@PING_STATE);
od;       
}
#endif
/* Property 18 */
/* Never claim for reachability to TRANSMIT_COMPUTE in 
Gateway when TDI packet to N0 is lost */
#ifdef P18
never
{
do
:: Daemon@PING_LS0->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@TRANSMIT_COMPUTE);
od;       
}
#endif
/* Property 19 */
/* Never claim for reachability to TTX_STATE in 
Gateway when PING packet to N0 is lost */
#ifdef P19
never
{
do
:: Daemon@PING_LS0->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@TTX_STATE);
od;       
}
#endif
/* Property 20 */
/* Never claim for reachability to REQUEST_STATE in 
Gateway when PING packet to N0 is lost */
#ifdef P20
never
{
do
:: Daemon@PING_LS0->break;
:: true;
od;
acceptall:
do
::!(G[pid0]@REQUEST_STATE);
od;       
}
#endif
/* Property 21 */
/* Never claim for reachability to PING_ACK_STATE in N1 when 
PING packet to N1 is lost */
#ifdef P21
never
{
do
:: Daemon@PING_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@PING_ACK_STATE);
od;       
}
#endif
/* Property 22 */
/* Never claim for reachability to UPDATE_TTX_STATE in 
N1 when PING packet to N1 is lost */
#ifdef P22
never
{
do
:: Daemon@PING_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 23 */
/* Never claim for reachability to REQUEST_PROCESS_STATE in 
N1 when PING packet to N1 is lost */

#ifdef P23 
never
{
do
:: Daemon@PING_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 24 */
/* Never claim for reachability to DATA_TRANSMIT_STATE in 
N1 when PING packet to N1 is lost */
#ifdef P24
never
{
do
:: Daemon@PING_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 25 */
/* Never claim for reachability to PING_ACK_STATE in 
N2 when PING packet to N2 is lost */
#ifdef P25
never
{
do
:: Daemon@PING_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@PING_ACK_STATE);
od;       
}
#endif
/* Property 26 */
/* Never claim for reachability to UPDATE_TTX_STATE in 
N2 when PING packet to N2 is lost */
#ifdef P26
never
{
do
:: Daemon@PING_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 27 */
/* Never claim for reachability to REQUEST_PROCESS_STATE in 
N2 when PING packet to N2 is lost */
#ifdef P27
never
{
do
:: Daemon@PING_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 28 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N2 when PING packet to N2 is lost */
#ifdef P28
never
{
do
:: Daemon@PING_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 29 */
/* Never claim for reachability to PING_ACK_STATE 
in N3 when PING packet to N3 is lost */
#ifdef P29
never
{
do
:: Daemon@PING_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@PING_ACK_STATE);
od;       
}
#endif
/* Property 30 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N3 when PING packet to N3 is lost */
#ifdef P30
never
{
do
:: Daemon@PING_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 31 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N3 when PING packet to N3 is lost */
#ifdef P31
never
{
do
:: Daemon@PING_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 32 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N3 when PING packet to N3 is lost */
#ifdef P32
never
{
do
:: Daemon@PING_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 33 */
/* Never claim for reachability to PING_ACK_STATE 
in N4 when PING packet to N4 is lost */
#ifdef P33
never
{
do
:: Daemon@PING_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@PING_ACK_STATE);
od;       
}
#endif
/* Property 34 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N4 when PING packet to N4 is lost */
#ifdef P34
never
{
do
:: Daemon@PING_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 35 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N4 when PING packet to N4 is lost */
#ifdef P35
never
{
do
:: Daemon@PING_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 36 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N4 when PING packet to N4 is lost */
#ifdef P36
never  
{
do
:: Daemon@PING_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 37 */
/* Never claim for reachability to PING_ACK_STATE 
in N4 when PING packet to N4 is lost */
#ifdef P37
never
{
do
:: Daemon@TTX_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@PING_ACK_STATE);
od;       
}
#endif
/* Property 38 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N1 when TDI packet to N1 is lost */
#ifdef P38
never
{
do
:: Daemon@TTX_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 39 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N1 when TDI packet to N1 is lost */
#ifdef P39
never
{
do
:: Daemon@TTX_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 40 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N1 when TDI packet to N1 is lost */
#ifdef P40
never
{
do
:: Daemon@TTX_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 41 */
/* Never claim for reachability to PING_ACK_STATE 
in N2 when TDI packet to N2 is lost */
#ifdef P41
never
{
do
:: Daemon@TTX_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@PING_ACK_STATE);
od;       
}
#endif
/* Property 42 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N2 when TDI packet to N2 is lost */
#ifdef P42
never
{
do
:: Daemon@TTX_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 43 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N2 when TDI packet to N2 is lost */
#ifdef P43
never
{
do
:: Daemon@TTX_LS2->break;
:: true;
od;
acceptall:
  do
::!(N[pid2]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 44 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N2 when TDI packet to N2 is lost */
#ifdef P44
never
{
do
:: Daemon@TTX_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 45 */
/* Never claim for reachability to PING_ACK_STATE 
in N3 when TDI packet to N3 is lost */
#ifdef P45
never
{
do
:: Daemon@TTX_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@PING_ACK_STATE);
od;       
}
#endif
/* Property 46 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N3 when TDI packet to N3 is lost */
#ifdef P46
never
{
do
:: Daemon@TTX_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 47 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N3 when TDI packet to N3 is lost */
#ifdef P47
never
{
do
:: Daemon@TTX_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 48 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N3 when TDI packet to N3 is lost */
#ifdef P48
never
{
do
:: Daemon@TTX_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 49 */
/* Never claim for reachability to PING_ACK_STATE 
in N4 when TDI packet to N4 is lost */
#ifdef P49
never
{
do
:: Daemon@TTX_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@PING_ACK_STATE);
od;       
}
#endif
/* Property 50 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N4 when TDI packet to N4 is lost */
#ifdef P50
never
{
do
:: Daemon@TTX_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 51 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N4 when TDI packet to N4 is lost */
#ifdef P51
never
{
do
:: Daemon@TTX_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 52 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N4 when TDI packet to N4 is lost */
#ifdef P52
never
{
do
:: Daemon@TTX_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 53 */
/* Never claim for reachability to PING_ACK_STATE 
in N1 when REQ packet to N1 is lost */
#ifdef P53
never
{
do
:: Daemon@REQ_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@PING_ACK_STATE);
od;       
}
#endif
/* Property 54 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N1 when REQ packet to N1 is lost */
#ifdef P54
never
{
do
:: Daemon@REQ_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 55 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N1 when REQ packet to N1 is lost */
#ifdef P55
never
{
do
:: Daemon@REQ_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 56 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N1 when REQ packet to N1 is lost */
#ifdef P56
never
{
do
:: Daemon@REQ_LS1->break;
:: true;
od;
acceptall:
do
::!(N[pid1]@DATA_TRANSMIT_STATE);
od;       
} 
#endif
/* Property 57 */
/* Never claim for reachability to PING_ACK_STATE 
in N1 when REQ packet to N1 is lost */
#ifdef P57
never
{
do
:: Daemon@REQ_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@PING_ACK_STATE);
od;       
} 
#endif
/* Property 58 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N2 when REQ packet to N2 is lost */
#ifdef P58
never
{
do
:: Daemon@REQ_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@UPDATE_TTX_STATE);
od;       
} 
#endif
/* Property 59 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N2 when REQ packet to N2 is lost */
#ifdef P59
never
{
do
:: Daemon@REQ_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@REQUEST_PROCESS_STATE);
od;       
} 
#endif
/* Property 60 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N2 when REQ packet to N2 is lost */
#ifdef P60
never
{
do
:: Daemon@REQ_LS2->break;
:: true;
od;
acceptall:
do
::!(N[pid2]@DATA_TRANSMIT_STATE);
od;       
} 
#endif
/* Property 61 */
/* Never claim for reachability to PING_ACK_STATE 
in N3 when REQ packet to N3 is lost */
#ifdef P61
never
{
do
:: Daemon@REQ_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@PING_ACK_STATE);
od;       
} 
#endif
/* Property 62 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N3 when REQ packet to N3 is lost */
#ifdef P62
never
{
do
:: Daemon@REQ_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 63 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N3 when REQ packet to N3 is lost */
#ifdef P63
never
{
do
:: Daemon@REQ_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@REQUEST_PROCESS_STATE);
od;       
}
#endif
/* Property 64 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N3 when REQ packet to N3 is lost */
#ifdef P64
never
{
do
:: Daemon@REQ_LS3->break;
:: true;
od;
acceptall:
do
::!(N[pid3]@DATA_TRANSMIT_STATE);
od;       
}
#endif
/* Property 65 */
/* Never claim for reachability to PING_ACK_STATE 
in N4 when REQ packet to N4 is lost */
#ifdef P65
never
{
do
:: Daemon@REQ_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@PING_ACK_STATE);
od;       
}
#endif
/* Property 66 */
/* Never claim for reachability to UPDATE_TTX_STATE 
in N4 when REQ packet to N4 is lost */
#ifdef P66
never
{
do
:: Daemon@REQ_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@UPDATE_TTX_STATE);
od;       
}
#endif
/* Property 67 */
/* Never claim for reachability to REQUEST_PROCESS_STATE 
in N4 when REQ packet to N4 is lost */
#ifdef P67
never 
{
do
:: Daemon@REQ_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@REQUEST_PROCESS_STATE);
od;       
} 
#endif
/* Property 68 */
/* Never claim for reachability to DATA_TRANSMIT_STATE 
in N4 when REQ packet to N4 is lost */
#ifdef P68
never
{
do
:: Daemon@REQ_LS4->break;
:: true;
od;
acceptall:
do
::!(N[pid4]@DATA_TRANSMIT_STATE);
od;       
} 
#endif