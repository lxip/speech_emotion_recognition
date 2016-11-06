% DRIVER TO EXPLORE THE SHAPE OF THE FITNESS LANDSCAPE USING THE COUNTER-PROPAGATION ANN
% AUTHOR: MAGGIE EPPSTEIN

% CREATE A RANDOM DATABASE OF PATIENTS (CLASS NOT YET KNOWN)
npatients=1000;
[data,normdata,nBoolvars,nRealvars]=fakeData(npatients); %make up fake answers to mental health questions


ntruevarstotryall=[2 5 10]; %CREATE TEST PROBLEMS WITH THESE MANY TRUE FEATURES IN THEM
nlocstotry=[1:10 50]; %EVALUATE FITNESS OF INDIVIDUALS WITH THESE MANY TOTAL FEATURES IN THEM
nreps=10;

symb='*o';
colr='gr';
ph=zeros(1,2);


for ntrue=1:length(ntruevarstotryall)
    ntruevarstotry=ntruevarstotryall(ntrue);
    figure(ntrue)
    clf
    for nvars=ntruevarstotry
        clf % start with a clean figure
        for reps=1:nreps
            % CREATE A RANDOM PROBLEM
            [tree,classes,truevars] = makemixedproblem(nvars,data,nBoolvars,nRealvars);
            % AND SPLIT IT INTO 80% TRAINING AND 20% TEST SETS
            [traindata,trainclasses,testdata,testclasses]=TrainTestSet(normdata,classes);
            
            % DETERMINE WHICH VARIABLES ARE NOT THE TRUE ONES
            allvars=1:size(normdata,2);
            falselocs=setdiff(allvars,truevars);
            falseincludelocs=falselocs(end-length(truevars)+1:end);
            
            % CREATE A PLACE FOR THE FITNESS RESULTS TO BE STORED
            error=zeros(length(nlocstotry),2); %1ST COLUMN WITH TRUE LOCS, 2ND COLUMN WITHOUT
            
            for trial=1:2
                if trial==1 %INCLUDE TRUE VARIABLES
                    includelocs=truevars;
                else % DON'T INCLUDE ANY OF THE TRUE VARIABLES
                    includelocs=falseincludelocs;
                end
                
                % MAKE FAKE POPULATIONS THAT HAVE SPECIFIC NUMBERS OF BITS ON AND
                % EITHER DO OR DON'T INCLUDE THE "TRUE" BITS ON
                pop=zeros(length(nlocstotry),size(normdata,2));
                for nn=1:length(nlocstotry)
                    N=nlocstotry(nn);  % create a chromosome with N bits on
                    features=[falselocs(1:N-length(includelocs)) includelocs(1:min(N,length(includelocs)))];
                    pop(nn,features)=1;
                end
                
                % NOW EVALUATE THE FITNESS OF THE CONSTRUCTED POPULATION
                error(:,trial)=fitnessCounterPropANN(pop,traindata,trainclasses,testdata,testclasses);
                
                ph(trial)=plot(nlocstotry',error(:,trial),[colr(trial) symb(trial) '-']);
                hold on
                figure(gcf)
                drawnow
            end
            
            
            
        end
        title(['Random problems with ',num2str(nvars),' variables']);
        legend(ph,'with truevars','w/o truevars')
        xlabel('number of features included')
        ylabel('root mean square classification error')
        hgsave([num2str(nvars),'vars.fig']); % SAVE RESULTS TO A FIGURE FILE
    end
end