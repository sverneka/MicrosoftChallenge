#include<cmath>
#include<cstdio>
#include<vector>
#include<string>
#include<fstream>
#include<sstream>
#include<iostream>

using namespace std;

#define NUMINS 28
#define ACTUAL_NUMINS 26

int main(int argc,char *argv[])
{
     int i,j,lineno ;
     int ngram = 0;
     vector<int> prgseq;
     vector<vector<int> > instructpos(ACTUAL_NUMINS,prgseq); 



     if(argc <=1 ) {
	fprintf(stderr,"The usage is %s infilename ngram\n",argv[0]);
        return -1;
     }
     istringstream line_arg(argv[2]);
     line_arg >> ngram; 

     fprintf(stderr,"filename = %s\n",argv[1]);
     fprintf(stderr,"determining %d gram histogram \n",ngram);

	
     ifstream in;
     in.open(argv[1],ios::in);
     string line;
     
     lineno = 0;

     int maxidx = 0;
     int actuallinecount = 0;
     while (getline(in, line)) {
         istringstream line_in(line);
         if(lineno == 2 || lineno == 5) {
         ++lineno;
         continue;
         }
         while (line_in) {
             if(lineno >= NUMINS) {
                  cerr <<"ERROR: line no > NUM Instr "<< lineno <<" > " << NUMINS << endl; 
                  break;
             }
             int val = 0;
             if (line_in >> val) {
                instructpos[actuallinecount].push_back(val);
                if(maxidx < val)
 			maxidx = val;
             }
         }
         ++lineno;
         ++actuallinecount;
         if(lineno > NUMINS) {
               cerr <<"ERROR: line no > NUM Instr "<< lineno <<" > " << NUMINS << endl; 
               --lineno;
               --actuallinecount;
               break;
         }
    }

    prgseq.assign(maxidx,-1);
    //cout<<"Number of lines = "<<lineno<<endl;

    for (i=0; i <actuallinecount; ++i){
        for(j=0 ; j < instructpos[i].size(); ++j )
           { 
             int index = instructpos[i][j] -1 ;
             if(index >= 0 && index <maxidx )
                  prgseq[ index ] = i ; 
             else 
                  cerr << " index"<<index <<" out of bounds " << maxidx <<endl;
          }
    }

    j = 0; 
    for (i=0; i<prgseq.size(); ++i)
       if( prgseq[i] != -1 )
           prgseq[j++] = prgseq[i];

    int nvalid_instr = j;

    //cout<<"\nTotal number of instructions "<< j <<endl;
    instructpos.empty();
    instructpos.clear();

    int nbins = pow(actuallinecount,ngram); 
          
    vector<int> hist (nbins,0);

    for (i=ngram; i <nvalid_instr; ++i) {
        int hist_idx = 0;
        for(j =0; j<ngram; ++j )
            hist_idx = hist_idx * actuallinecount + prgseq[i-j];

        (hist[hist_idx])++;
    }

    for (i=0; i < nbins; ++i)
         cout<<" "<<hist[i] ;

    cout<<endl;

    return 0;
}
