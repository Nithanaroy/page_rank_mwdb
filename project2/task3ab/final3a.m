function [U S V outputV ]  = final3a(collection, r)
%This function will get r as input and return top r latent semantics using
%SVD
 
%Calling MongoDB and get the collection
javaaddpath('mongo-java-driver-2.12.3.jar');
import('com.mongodb.*');
mongoClient = MongoClient();
db = mongoClient.getDB( 'epidemic' );
coll = db.getCollection(collection); 

hash = java.util.Hashtable;
searchQuery =  BasicDBObject();
        %Declaring cursors to fetch data from MongoDB
        cur = coll.find(searchQuery);
        n = 1; count = 1; collectionWin = [];counta = 1;
        colle.states = {}; i = 1;
        while cur.hasNext()
            
            collectionFile{count} = cur.next().get('f');
           
        	 collectionWin{counta} = cur.curr().get('win');
        
          counta  = counta + 1;count = count + 1;
          
            n = n+ 1;
            i = i + 1;
        end
      %Getting all the unique values
         
         uniqueFileNames = unique(collectionFile);
 
        
        uniqueWindow = unique(collectionWin);
         %Declaring the svd matrix
 buildMatrix = zeros(length(uniqueFileNames),length(uniqueWindow));
  
fileCount =  length(uniqueFileNames);
%Fill the object feature matrix containing filenames as objects and
%features as distinct windows
  for i = 1 : length(uniqueFileNames)
      
   for j = 1:length(uniqueWindow)
    
       
        dbFileName = uniqueFileNames{i};
        dbWin = uniqueWindow{j};
        
       searchQuery =  BasicDBObject();
         searchQuery.put('f',dbFileName);	
         searchQuery.put('win',dbWin);	
         
         curCount = coll.find(searchQuery).count();
        buildMatrix(i,j) = curCount;
        
       
        
    end
  end
  
 
 % printing the latent semantics
 x = [];
    [U S V] = svd(buildMatrix);
    outputV = V(1:r,:);
    for i = 1:r
        fprintf('Latent semantics \t %d\n',i);
        for j = 1 : length(uniqueFileNames)
         simulation{j} = uniqueFileNames{j};
        % taking first r columns of U matrix which resulted from SVD
         h{j} = U(j,i:i);
         
        end
        columnResult = cell2mat(h);
        sortedResult = sort(columnResult,'descend');
        %Print <simulation,score>
        count = 1;
        for jh = 1:length(sortedResult)
          for rf = 1:length(h)  
          if  sortedResult(jh) == h{rf}
              h{rf} = 11111111111111111;
            fprintf('%s  \t %f\n',simulation{rf} , sortedResult(jh));
            break;
          end
          end
         
        end  
        
    
     
    end
end


