function d = dtw(w1,w2)

if size(w1,2)~=size(w2,2)
    error('The number of dimensions in both inputs are not equal.');
end

lengthw1=length(w1);
lengthw2=length(w2);

% distance matrix to dynamic programming cache
dists = Inf(lengthw1+1,lengthw2+1); % infinity at first
dists(1,1) = 0;

% dtw dynamic programming algorithm
for iw1 = 1:lengthw1
    for iw2 = 1:lengthw2
        w1w2dist = norm(w1(iw1,:)-w2(iw2,:));
        dists(iw1+1,iw2+1) = w1w2dist + min( [dists(iw1,iw2+1), dists(iw1+1,iw2), dists(iw1,iw2)] );
    end
end
d = dists(lengthw1+1,lengthw2+1);
