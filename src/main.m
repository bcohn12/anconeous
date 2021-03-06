% Foundation code for stroke arm model.

% August 2015 H Bacon, A Hooyman, K M Rowley

clear all
%%

% SET-UP

% Number of Postures (Max 2 => see line 62-64)
numPostures=2;
% Number of iterations for Monte Carlo
numIt=100;

% Geometric model of the arm:
syms l1 l2 q1 q2 q3 q4 % variables include limb lengths and joint angles
T10=[cos(q1) 0 sin(q1) 0;0 1 0 0;-sin(q1) 0 cos(q1) 0; 0 0 0 1];
T21=[cos(q2) -sin(q2) 0 0;sin(q2) cos(q2) 0 0;0 0 1 0;0 0 0 1];
T32=[1 0 0 0;0 cos(q3) -sin(q3) 0;0 sin(q3) cos(q3) 0;0 0 0 1];
T43=[cos(q4) 0 sin(q4) -l1;0 1 0 0;-sin(q4) 0 cos(q4) 0;0 0 0 1];
T54=[1 0 0 -l2;0 1 0 0;0 0 1 0; 0 0 0 1];
T50=T10*T21*T32*T43*T54; % concatenate matrices
HAND=T50(1:3,4); % extract geometric model
HANDfn=matlabFunction(HAND); % make it a matlab function so that we can vary posture

% Geometric model of the upper limb (shoulder to elbow):
E10=[cos(q1) 0 sin(q1) 0;0 1 0 0;-sin(q1) 0 cos(q1) 0; 0 0 0 1];
E21=[cos(q2) -sin(q2) 0 0;sin(q2) cos(q2) 0 0;0 0 1 0;0 0 0 1];
E32=[1 0 0 -l1;0 1 0 0;0 0 1 0;0 0 0 1];
E30=E10*E21*E32;
ELBOW=E30(1:3,4); % extract geometric model
ELBOWfn=matlabFunction(ELBOW); % make it a matlab function

% Caculate partial derivatives for Jacobian
dxdq1=diff(HAND(1),q1);
dxdq2=diff(HAND(1),q2);
dxdq3=diff(HAND(1),q3);
dxdq4=diff(HAND(1),q4);

dydq1=diff(HAND(2),q1);
dydq2=diff(HAND(2),q2);
dydq3=diff(HAND(2),q3);
dydq4=diff(HAND(2),q4);

dzdq1=diff(HAND(3),q1);
dzdq2=diff(HAND(3),q2);
dzdq3=diff(HAND(3),q3);
dzdq4=diff(HAND(3),q4);

J=[dxdq1 dxdq2 dxdq3 dxdq4; dydq1 dydq2 dydq3 dydq4; dzdq1 dzdq2 dzdq3 dzdq4];
Jfn=matlabFunction(J); % Make Jacobian calculation a matlab function

% Set-up Arm Parameters

% Set the segment lengths
l1 = 0.3; % upper arm (m)
l2 = 0.3; % lower arm (m)

% Set up arm postures
q1=[0,-45].*(pi/180); % shoulder vertical rotation (rad)
q2=[-45,0].*(pi/180); % shoulder horizontal rotation (rad)
q3=[90,0].*(pi/180); % shoulder internal rotation (rad)
q4=[90,90].*(pi/180); % elbow flexion (rad)
Q=[q1;q2;q3;q4];

% Set-up Muscle Paramters
numMuscles=18;

% Physciological cross sectional area (PCSA) of all muscles in model (cm^2):
PCSA=[8.2, 8.2, 1.9, 3.5, 8.6, 9.8, 2.5, 3.0, 9.1, 7.6, 1.7, 5.7, 9, 2.5, 4.5, 3.1, 7.1, 1.9];
% MONTE CARLO: Vary the PCSA from 0.5 to 1.5 times the original value
PCSAlb=0.5; PCSAub=1.5;
% generate samples from uniform distribution of PCSA scaling factors
PCSAr=random('unif',PCSAlb,PCSAub,numIt,numMuscles);

sigmamax=35; % N/cm^2

pennation=[22,15,18,7,19,20,24,16,22.333,21.667,27,12,9,0,0,0,0,0].*(pi/180);

% Optimal Fibre Lengths (m)
M_opt=[0.098, 0.108, 0.137, 0.068,0.076,0.087,0.074,0.162,0.140,0.255,0.093,0.134,0.114,0.027,0.116,0.132,0.086,0.173];

% Length-Tension Relationship parameter
w = 0.5;

% MONTE CARLO: Vary Moment Arms between upper and lower bounds in literature
% Moment arms (m) - lower bound determined from range in literature
Rlb = [0.02, -0.01, 0,0;... % delt ant
    0.01,0.01,0,0;... % delt mid
    -0.06,-0.06,0,0;... % delt post
    0,0.02,-0.01,0;... % supraspinatus
    0,0.01,-0.02,0;... % infraspinatus
    0,0.005,0.01,0;... % sub scapularis
    0,-0.015,-0.0225,0;... % teres minor
    -0.045,-0.035,0,0;... % teres major
    0.01,-0.05,0,0;... % pecs
    -0.0425,-0.02,0,0;... % lats
    0.015,-0.025,0,0;...% corabrachialis
    -0.022,0,0,-0.021;... % triceps long
    0,0,0,-0.021;... % triceps short
    0,0,0,-0.014;...% anconeus
    0.032,0,0,0.04;... % bicpes long
    0,0,0,0.04;... % biecps short
    0,0,0,0.02;... % brachialis
    0,0,0,0.04]';... % brachioradialis
    % Moment arms (m) - upper bound determined from range in literature
Rub = [0.05, 0.01, 0,0;... % delt ant
    0.02,0.05,0,0;... % delt mid
    -0.01,0.01,0,0;... % delt post
    0,0.03,-0.005,0;... % supraspinatus
    0,0.03,-0.01,0;... % infraspinatus
    0,0.015,0.03,0;... % sub scapularis
    0,-0.005,-0.0175,0;... % teres minor
    -0.04,-0.0325,0,0;... % teres major
    0.04,-0.0175,0,0;... % pecs
    -0.02,-0.005,0,0;... % lats
    0.025,-0.015,0,0;...%corabrachialis
    -0.020,0,0,-0.019;...% triceps long
    0,0,0,-0.019;...% triceps short
    0,0,0,-0.010;...% anconeus
    0.040,0,0,0.06;... % biceps long
    0,0,0,0.06;... % biceps short
    0,0,0,0.03;...% brachialis
    0,0,0,0.08]';... % brachioradialis
    % Generate a Moment Arm Matrix for each subject from uniform distribution of values
for muscle=1:numMuscles
    for dof=1:4
        Rr(:,dof,muscle)=random('unif',Rlb(dof,muscle),Rub(dof,muscle),numIt,1);
    end
end

%%
% Run model

for sub=1:numIt % run for each unique subject (i.e. the Monte Carlo analysis)
    for posnum=1:numPostures
        
        % Calculate musculotendon lengths
        M=-squeeze(Rr(sub,:,:))'*Q(:,posnum);
        
        % Normalize lengths
        M_norm=M'./M_opt;
        
        % Calculate force factor for each muscle
        for n=1:length(M_opt) %number of muscles
            if M_norm(n)<=-0.5 || M_norm(n)>=0.5
                FL(n)=0; % no force production at this length
            else
                FL(n)=1-(M_norm(n)/w)^2;
            end
        end
        
        % Calculate max force matrix
        F0 = sigmamax.*diag(PCSA)*diag(PCSAr(sub,:))*diag(FL)*diag(cos(pennation));
            %sigmamax; PCSA(18); subject scaling factor; Force-Length factor(18); pennation(18)
        
        J_inv_t=pinv(Jfn(l1,l2,q1(posnum),q2(posnum),q3(posnum),q4(posnum)))'; % Calculate J^-T
        hand=HANDfn(l1,l2,q1(posnum),q2(posnum),q3(posnum),q4(posnum)); % Get position of hand (endpoint)
        elbow=ELBOWfn(l1,q1(posnum),q2(posnum)); % Get position of elbow
        
        % Multiply matrices
        c1 = J_inv_t*squeeze(Rr(sub,:,:))*F0;
        cx1 = c1(1, :);
        cy1 = c1(2, :);
        cz1 = c1(3, :);
        
        % OPTIMIZATION: Find maximum x force in negative direction
        f = -1*cz1+0.01*ones(1,numMuscles); % cost function based on force and activation
        epsilon = 0.1; % tolerance
        % Set up constraint matrices
        A = [eye(numMuscles); -eye(numMuscles); cy1; -cy1; cx1; -cx1]; % Constraints on activation, force in y, x
        b = [ones(1,numMuscles), zeros(1,numMuscles), epsilon, -epsilon, epsilon, -epsilon]; % activation between 0 and 1, force in y and x zero +- epsilon.
        % Linear programming
        Z = linprog(f, A, b);
        if length(Z) ~= numMuscles % i.e. failed to compute a solution
            Z=zeros(numMuscles,1);
        end
        Fx1 = cx1*Z;
        Fy1 = cy1*Z;
        Fz1(posnum) = cz1*Z;
        MaxForce = [Fx1 Fy1 Fz1(posnum)];
        
        % Plot of Arm Posture
        if sub==1
            [sa,sb,sc]=sphere; % get points on a sphere for plotting shoulder position
            sr=0.02; % set radius of sphere
            figure(posnum);
            line([0,elbow(1)],[0,elbow(2)],[0,elbow(3)],'LineWidth',4); hold on;
            line([elbow(1),hand(1)],[elbow(2),hand(2)],[elbow(3),hand(3)],'LineWidth',4);hold on;
            fill3([hand(1),hand(1),hand(1),hand(1)],[hand(2)+.1,hand(2)-.1,hand(2)-.1,hand(2)+.1],[hand(3)-.1,hand(3)-.1,hand(3)+.1,hand(3)+.1],'r');
            xlabel('X'),ylabel('Y'),zlabel('Z');
        end
    end
end

save('Aug2015Anconeus')
