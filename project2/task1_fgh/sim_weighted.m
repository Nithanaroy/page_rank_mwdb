function similarity = sim_weighted( collection, location_matrix_filename, f1, f2, win_search_dist)
%SIM_WEIGHTED_WORD Summary of this function goes here
%   Detailed explanation goes here

if win_search_dist == 0
    win_search_dist = 1e-8;
end

% initialize mongo
javaaddpath('mongo-java-driver-2.12.3.jar');
import('com.mongodb.*');
mongoClient = MongoClient();
db = mongoClient.getDB( 'epidemic' );
wcoll = db.getCollection(collection);
query = BasicDBObject();
query.put('f', f1);
query.put('s', 'AZ');
fields = BasicDBObject();
fields.put('_id', false);
fields.put('t', true);
sortfields = BasicDBObject();
sortfields.put('t', -1);
cursor = wcoll.find(query, fields).sort(sortfields).limit(1);
dbobject = cursor.next();
max_time = dbobject.get('t');

% get state distances
[distmat, stateRefs] = states_distance( location_matrix_filename );

% get wins1
[wins1mat, wins1List] = getDistinctWins(f1);
wins1weight = win_weight(wins1List);

% get wins2
[wins2mat, ~] = getDistinctWins(f2);
wins2searcher = ExhaustiveSearcher(wins2mat, 'Distance', 'cosine');

% get similarity of f1 in f2
f1inf2sim = getsimsfromB(wins2searcher, wins1weight, wins1mat, f1, wins2mat, f2);

similarity = f1inf2sim;

java.lang.System.gc();

%% helper functions
    function simofAinB = getsimsfromB(B_searcher, A_weights, A_wins, A_f, B_wins, B_f)
        import('com.mongodb.*');
        A_length = size(A_wins,1);
        A_wins_sim = Inf(1, A_length);
        
        %% for each win in A
        for A_i = 1:A_length
            % get win A
            A_win = A_wins(A_i, :);
            
            % find an exact win match in B
            [~,B_win_idxes] = ismember(A_win, B_wins, 'rows');

            % find all similar B wins to win A
            B_win_idxes = rangesearch(B_searcher, A_win, win_search_dist);
            B_win_idxes = B_win_idxes{1};

            
            if numel(B_win_idxes) == 0
                % could not find a matching win
                A_wins_sim(A_i) = 0;
            else

                % find all s, t pair in win A
                query = BasicDBObject();
                query.put('win', num2str(A_win));
                query.put('f', A_f);
                fields = BasicDBObject();
                fields.put('_id', false);
                fields.put('s', true);
                fields.put('t', true);
                A_cursor = wcoll.find(query, fields);        

                %% find average of similar among all s, t in win A
                sum_sim = 0;
                num_candidates = 0;

                while A_cursor.hasNext()
                    A_obj = A_cursor.next();
                    A_state = A_obj.get('s');
                    A_time = A_obj.get('t');

                    %% find the most similar (win, s, t) in B
                    most_similar_win_s_t = 0;
                    % for each (win, s, t) in B
                    for B_i = 1:length(B_win_idxes)
                        if most_similar_win_s_t ~=1
                            % get B win
                            B_win = B_wins(B_win_idxes(B_i), :);

                            AB_win_sim = win_pair_sim(A_win, B_win);


                            % prepare query and fields to find all (s, t)'s of B win
                            query = BasicDBObject();
                            query.put('win', num2str(B_win));
                            query.put('f', B_f);
                            fields = BasicDBObject();
                            fields.put('_id', false);
                            fields.put('s', true);
                            fields.put('t', true);

                            B_cursor = wcoll.find(query, fields);

                            % for each s, t in win B

                            while B_cursor.hasNext()
                                B_obj = B_cursor.next();
                                B_state = B_obj.get('s');
                                B_time = B_obj.get('t');

                                AB_s_t_sim = s_t_pair_sim(A_state, A_time, B_state, B_time);

                                % aggregate similarity
                                AB_sim = AB_win_sim * AB_s_t_sim;

                                % update most similar
                                if AB_sim == 1
                                    most_similar_win_s_t = 1;
                                    break;
                                elseif AB_sim > most_similar_win_s_t
                                    most_similar_win_s_t = AB_sim;
                                end
                            end
                        end
                    end


                    sum_sim = sum_sim + most_similar_win_s_t;
                    num_candidates = num_candidates + 1;
                end
                A_wins_sim(A_i) = sum_sim/num_candidates;
            end
        end
        simofAinB = dot(A_weights, A_wins_sim);
    end

    function [winsmatdistinct, winsListDistinct] = getDistinctWins(f)
        import('com.mongodb.*');
        query = BasicDBObject();
        query.put('f', f);
        winsListDistinct = wcoll.distinct('win', query);
        winsmatdistinct = str2num(winsListDistinct.toArray());
    end

    function s_t_sim = s_t_pair_sim(s1, t1, s2, t2)
        s1_idx = stateRefs(s1);
        s2_idx = stateRefs(s2);
        s_dist = distmat(s1_idx, s2_idx);
        s_sim = 1/(1+s_dist);
        t_dist = abs(t1 - t2) / max_time;
        t_sim = 1 - t_dist;
        s_t_sim = s_sim * t_sim;
    end

    function win_sim = win_pair_sim(win1, win2)
        win_dist = pdist2(win1, win2, 'cosine');
        win_sim = 1 - win_dist;
    end

    function weights = win_weight(winsDistinctList)
        import('com.mongodb.*');
        winsTotal = wcoll.count();
        winsListSize = winsDistinctList.size();
        winsIterator = winsDistinctList.iterator();
        wins_tf = zeros(1, winsListSize);
        wi = 1;
        while winsIterator.hasNext()
            win = winsIterator.next();
            
            query = BasicDBObject();
            query.put('win', win);
            
            % get count of win in file
            winCount = wcoll.find(query).count();
            % caculate term frequency
            wins_tf(wi) = winCount/winsTotal;
            
            wi = wi + 1;
        end
        max_win_tf = max(wins_tf);
        half_weight = 0.5/max_win_tf;
        % Salton and Buckley TF formula
        sb_win_tf = 0.5 + (half_weight * wins_tf);
        % weight of win is inversely proportional to term frequency
        inv_wins_probability = 1./sb_win_tf;
        % normalize such that sum of weights are 1
        weights = inv_wins_probability / norm(inv_wins_probability, 1);
    end


    % calculate state distance
    function [distmat, stateRefs] = states_distance( location_matrix_filename )

        [~,~,ext] = fileparts(location_matrix_filename);
        % parse file
        if strcmpi(ext, '.xlsx')
            [nbmat, gtext, ~] = xlsread(location_matrix_filename);
            statenames = gtext(1, 2:end);
        else strcmpi(ext, '.csv')
            celldata = read_mixed_csv(location_matrix_filename, ',');
            statenames = celldata(1, 2:end);
            nbmat = str2double(celldata(2:end,2:end));
        end

        distmat = allspath(nbmat);
        stateRefs = containers.Map(statenames, 1:length(statenames)); 

    end

    % calculate shortest path distance matrix from adjacency matrix
    function B = allspath(A)
        B=full(A);
        B(B==0)=Inf;
        C=ones(size(B));
        while any(C(:))
            C=B;
            B=min(B,squeeze(min(repmat(B,[1 1 length(B)])+...
                repmat(permute(B,[1 3 2]),[1 length(B) 1]),[],1)));
            C=B-C;
        end
        B(logical(eye(length(B))))=0;
    end
end

