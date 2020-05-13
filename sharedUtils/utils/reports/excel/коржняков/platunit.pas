unit platunit;

interface
type
tbank=record
   Name:string[80];
   Bik:string[20];
   Ks:string[30];
      end;

turlc=record
   Name:string[80];
   INN:string[20];
   RS:string[30];
   bank:tbank;
   adres:string[170];
   telefon:string[40];
      end;

tpp=record
   npp:string[20];
   datepp:string[10];
   cvidpl:string[20];
   summp:string[20];
   summpp:string[150];

   plName:string[200];
   plINN:string[80];
   plRS:string[30];
   bplName:string[200];
   bplBik:string[20];
   bplKs:string[30];

   polName:string[200];
   polINN:string[80];
   polRS:string[30];
   bpolName:string[200];
   bpolBik:string[20];
   bpolKs:string[30];

   vidop:string[20];
   srokop:string[20];
   nazpl:string[20];
   ocherpl:string[20];
   kod:string[20];
   rezpole:string[20];
   mnazpl:string[250];
   end;


tsf=record
   kod_doc:string[10];
   nsf:string[20];
   datesf:string[10];

   prodav:turlc;
   GOTP:string[250];
   GPOL:string[250];
   npld:string[20];
   dpld:string[10];
   pokup:turlc;

   tabl:array[1..20]of record
   a:string[100];
   b:string[20];
   c:string[20];
   d:string[20];
   e:string[20];
   f:string[20];
   g:string[20];
   h:string[20];
   i:string[20];
   j:string[20];
   k:string[50];
   l:string[20];
   r1:string[20];
   r2:string[20];
   r3:string[20];
   l1:string[50];
                       end;
   ee:currency;
   ff:currency;
   gg:currency;
   hh:currency;
   ii:currency;
   jj:currency;
   summ_sfp:string[150];
   r1:currency;
   r2:string[50];
   end;


tpko=record
     kod_doc:string[10];
     npko:string[20];
     datepko:string[10];

     orNAME:string[80];
     pdNAME:string[80];

     dbt:string[20];
     kodp:string[20];
     kors:string[20];
     koda:string[20];
     summp:string[20];
     summpko:string[150];
     kodc:string[20];

     plt:turlc;
     osn:string[150];
     vtcl:string[70];
     pril:string[70];
     end;



var
errorBDE:integer;
bank:tbank;


platel:turlc;
polut:turlc;


pp:tpp;
pko:tpko;

sf:tsf;


implementation

end.
