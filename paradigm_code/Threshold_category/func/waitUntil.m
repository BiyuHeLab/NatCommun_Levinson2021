function waitUntil(t0,duration)
% waitUntil(t0,duration)
%
% Wait until "duration" seconds have passed from t0.
%
% t0 : specified by GetSecs
% duration : the duration to wait after t0, in seconds

while GetSecs < t0 + duration
    ;
end