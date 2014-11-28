function [ DocProb wordProb DP WP]  = final3b(collection, r)
%This function will use LDA to return top r latent semantics
%   Calling MongoDB
javaaddpath('mongo-java-driver-2.12.3.jar');
import('com.mongodb.*');
mongoClient = MongoClient();
db = mongoClient.getDB( 'epidemic' );
coll = db.getCollection(collection); 

hash = java.util.Hashtable;
searchQuery =  BasicDBObject();
        
        cur = coll.find(searchQuery);
        n = 1; count = 1; collectionWin = [];counta = 1;
        colle.states = {}; i = 1;
        %Cursor for looping through all the data in mongoDB
        while cur.hasNext()
           
            collectionFile{count} = cur.next().get('f');
          
        	 collectionWin{counta} = cur.curr().get('win');
          counta  = counta + 1;count = count + 1;
          
        end
 %getting unique values for all the fields in mongoDB
       
         uniqueFileNames = unique(collectionFile);
 
         uniqueWindow = unique(collectionWin);
         
 buildMatrix = zeros(length(uniqueFileNames),length(uniqueWindow));
 % building the object feature matrix where object are filenames and
 % features are distinct windows or words 
  
  for i = 1 : length(uniqueFileNames)
      
   for j = 1:length(uniqueWindow)
    
        %column = j * k;
        dbFileName = uniqueFileNames{i};
        dbWin = uniqueWindow{j};
        
        searchQuery =  BasicDBObject();
         searchQuery.put('f',dbFileName);	
         searchQuery.put('win',dbWin);	
         
         curCount = coll.find(searchQuery).count();
        
        buildMatrix(i,j) = curCount;
        
       
        
    end
  end
  %Building the inputs to gibbssamplerLDA converting the bag of words to 2
  %matrices where WS contains word  indices for the kth token and DS
  %contains document indices for kth token
 [rows columns] = size(buildMatrix);
 id = 0; indices = 1;
 for i = 1 : rows
     for j = 1:columns
       if buildMatrix(i,j) > 0
           id = 0;
         while(id < buildMatrix(i,j))
           WS(indices) = j;
           DS(indices) = i;
           indices = indices + 1;
           id = id + 1;
         end
       end
     end
 end
 W = length(uniqueWindow);
%Set the hyperparameters alpha denotes topic strength and beta denotes
%feature strength and it is fixed for this GibbsSamplerLDA library
% |ALPHA| and |BETA| are the hyper parameters on the Dirichlet priors for the topic 
% distributions (|theta|) and the topic-word distributions (|phi|)respectively
ALPHA = 50/r; 
BETA = 200/W;%0.01
%The number of iterations
N = 500;
%The random seed


SEED = 3; %|SEED| sets the seed for the random number generator
%output to show (0=no output; 1=iterations; 2=all output)
OUTPUT = 2; 
 [ WP,DP,Z ] = GibbsSamplerLDA( WS , DS , r , N , ALPHA , BETA , SEED , OUTPUT );
 % 1 is threshold for topic listings, Only
% entities that do not exceed this cumulative probability are listed.
[ DocProb ] = WriteTopic( DP , BETA , uniqueFileNames , length(uniqueFileNames) , 1 , r , 'topics.txt' ); %Desired output for project as <simulation,score>
[ wordProb ] = WriteTopic( WP , BETA , uniqueWindow , length(uniqueWindow) , 1 , r , 'topicsWord.txt' ); 
wordProb = transpose(wordProb);
end


