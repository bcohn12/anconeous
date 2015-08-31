#Postures – 2
              q1    q2    q3   q4
First (ABD):   0,  -45,  90,  90
Second (ADD): -45,  0,    0,  90

#Segment Lengths
Upper Arm: 0.3 m
Forearm and Hand: 0.3 m

#Muscles – 18
SigmaMax = 35 N/cm^2
Length-Tension Relationship Parameter = 0.5
#Moment Arms from a range reported in literature
PCSA
(cm^2)	`8.2	8.2	1.9	3.5	8.6	9.8	2.5	3.0	9.1	7.6	1.7	5.7	9.0	2.5	4.5	3.1	7.1	1.9`
Penn.
(°)	`22	15	18	7	19	20	24	16	22.3	21.7	27	12	9	0	0	0	0	0`
Mopt
(mm)`	98	108	137	68	76	87	74	162	140	255	93	134	114	27	116	132	86	173`

#Monte Carlo
PCSA varied 0.5 to 1.5 times literature value

Moment Arms varied using a lower bound and upper bound of literature-reported values

#Model
PCSAr == PCSA scaling factors between 0.5 to 1.5 for each subject (1000 Subjects, 18 Muscles)

Rr == Moment Arm Matrix (1000 Subjects, 4 DOFs, 18 Muscles)
M == Muscle Lengths for the given posture (18 Muscles)

M_norm == Muscle Lengths normalized to M_opt (18 Muscles)

FL == Force-Length Factor based on Length-Tension Relationship (18 Muscles)

F0 == Muscle Force Matrix

J_inv_t == Inverse Jacobian for the given posture

hand == location of hand

elbow == location of elbow

#Optimization – Maximum Force Normal to wall (positive z direction)
	c1 = J^-1 * R * F0

	Cost = -1*cz1 + 0.01*ones(1,18 Muscles) [maximize force in positive z, minimize activations)

	Epsilon = 0.1

	A = [ I(18,18); -I(18,18); cy1; -cy1; cx1; -cx1 ]

	b = [ ones(1,18), zeros(1,18), epsilon, -epsilon, epsilon, -epsilon ];

	Z = linprog(cost, A, b)

	MaxForce = [ cx1*Z; cy1*Z; cz1*Z ];
	
#Plot
Visualize Arm Posture
