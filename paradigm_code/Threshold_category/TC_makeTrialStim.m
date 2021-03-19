% Prepare image stimulus for presentation, adjust here contrast, size or 
% color if needed
function stimTex = TC_makeTrialStim(win, param, stimID)    
        
%Prep this before experiment
    load(param.pic_dir);
    if numel(param.stimContrast) > 1 %if there is individual contrast for each exemplar
        contrast = param.stimContrast(stimID);
    else
        contrast = param.stimContrast;
    end
%end prep    
    if param.graded
        minC = 0.01;
        maxC = contrast;
        nC = param.stimDuration_inFrames;        
        as_grad_contr = minC:(maxC - minC)/(nC - 1):maxC;
        ds_grad_contr = fliplr(as_grad_contr);                
        grad_contr = [as_grad_contr, ds_grad_contr(2:end)];
        stimTex = zeros(1, param.stimDuration_inFrames);
        for i = 1:(2*param.stimDuration_inFrames - 1)
            F = grad_contr(i) * (param.filter);   
            img = uint8(param.BGcolor * imdata .* F + param.BGcolor);
%             if i == param.stimDuration_inFrames
%                figure;imshow(img);
%                print([param.pic_dir], '-djpeg');%print(['proc_', param.pic_dir], '-djpeg');
%                 close;
%             end
            stimTex(i) = Screen('MakeTexture', win, img);  
        end
    else
        F = contrast * (param.filter);   
        imdata = uint8(double(imdata).*(F) + param.BGcolor);   
        stimTex = Screen('MakeTexture', win, imdata);  
    end
end