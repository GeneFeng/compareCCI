compareCCI
===
compareCCI is a tool for analyzing different cell-cell communication between different groups (normal and tumor) or different conditions (treatment and control). The analysis process is as follows:

#### step 1. Use the normalized counts matrix generated from Seurat as the input file. Each sample generates a file with Gene Symbol as row name and Cell barcode as column name. The format is as follows:
>
>gene	O2_AAACCCAAGCGTGAGT-1	O2_AAACCCAAGTAAGAGG-1	O2_AAACCCACAACAAAGT-1	O2_AAACCCACACGTACTA-1	O2_AAACCCACATTGCTTT-1	O2_AAACCCATCAAGAGGC-1	O2_AAACCCATCATGAGAA-1
Gm19938	0	0	0	0	0	0	0
Mrpl15	0	0	0	0	0	0	0.836548908
Lypla1	0	0	0	2.903692602	0	1.784298604	0
Tcea1	0	0	0	0	0	0	0.836548908
Atp6v1h	0	0	0	0	0	0	0
Rb1cc1	0	0	0	0	0	1.784298604	0
>
>All sample files are placed in the folder normalized_counts.

#### step 2. Run
```perl
perl LRexp.pl -c normalized_counts -a cell_annotation.txt -d LR_database.txt
```
>
>This step calculates the expression of ligands and receptors in different cells. Among them, cell_annotation.txt is the cell annotation file of all samples. The first column is the barcode name, and the second column is the cell type. The format is as follows:
>
>barcode	cellType
O1_AAACCCAAGCAGAAAG-1	Neutrophil
O1_AAACCCAAGCGTATGG-1	Neutrophil
O1_AAACCCAAGGCGAACT-1	Naive B cell
O1_AAACCCACAAATACAG-1	Fibroblast
O1_AAACCCACACCGTGAC-1	Fibroblast
O1_AAACCCACACCTCAGG-1	Basophil
O1_AAACCCACAGGTGACA-1	Mast cell
O1_AAACCCACATGGACAG-1	Neutrophil
O1_AAACCCAGTATCTTCT-1	Macrophage
O1_AAACCCAGTCATCGCG-1	Fibroblast
>
>Note: Barcode names may overlap between different samples. To distinguish, the sample name needs to be added in front of the barcode. Finally, ensure that the barcode name is consistent with the cell barcode in the normalized counts file.
>
>LR_database.txt is a manually curated ligand-receptor database. We integrated mouse ligands and receptors from three databases: CellChat, CytoTalk, and celltalkDB. Users can also define the database themselves, in the following format:
>
>ligand	receptor
A2m	Lrp1
Aanat	Mtnr1a
Aanat	Mtnr1b
Ace	Agtr2
Ace	Bdkrb2
Ada	Adora1
Ada	Adora2b
Ada	Dpp4
Adam10	Axl
>
>The first column is the ligand and the second column is the receptor.
>
>Output the folder lr_tr_cell, which contains the corresponding ligand and receptor expression in each cell of all samples. The format is as follows:
>
>ligand	receptor	cell_from_mean_exprs	cell_from	cell_to_mean_exprs	cell_to
Ada	Adora2b	0.0340165744927523	Erythroblast	0.00579164113556388	Erythroblast
Ada	Adora2b	0.0340165744927523	Erythroblast	0.140537284672739	Fibroblast
Ada	Adora2b	0.0340165744927523	Erythroblast	0.00618924096042447	B cell
Ada	Adora2b	0.0340165744927523	Erythroblast	0.00386360469068607	CD8 effector memory T cell
Ada	Adora2b	0.0340165744927523	Erythroblast	0.00742336096690841	Naive B cell

#### step 3. Run
```perl
perl LRscore.pl -d lr_tr_cell
```
>
>This step calculates the ligand-receptor interaction scores (LRscore) for different cell pairs. "lr_tr_cell" is the folder that stores the LR expression obtained in the previous step. The output results are the folder "merge_celltype" and the file "merge_celltype.txt". 
>
>"merge_celltype" includes the score of the ligand receptor, which is stored in different cell pairs. The format is as follows:
>
>sample	O1.norm_exp	O2.norm_exp	O3.norm_exp	Y1.norm_exp	Y2.norm_exp	Y3.norm_exp
Cd48|Cd244a	0.00133969277955394	0.00391021915676158	0.00336604527908225	0.00603279581105832	0.00129756261222217	0.00320216518808127
Cd84|Cd84	0.020095145907206	0.025206582082959	0.0272519163463504	0.0317181735453552	0.0378040130383532	0.0449430693002365
Cfh|Sell	0.00427550190435078	0.00183540259665721	0.00437072285249835	0.00320479767553492	0.000607041301914194	0.00235952189574622
Cntn2|Cntn2	8.21033129094134e-007	0	0	0	2.79085444696625e-006	0
F11r|F11r	1.37152915298106e-005	2.39733637137885e-005	2.25931441597501e-005	2.15905734094119e-005	2.5497745027597e-005	2.16640738812221e-005
>
>Users can view LR scores in cell pairs of interest. "merge_celltype.txt" is the result after merging all cell pairs.



#### step 4. Run
```perl
perl LRcompare.pl merge_celltype.txt 5,6,7 2,3,4
```
>
>This program performs a permutation test on two sets of LR scores. "merge_celltype.txt" is the LRscore file obtained in the previous step. "5, 6, 7" and "2, 3, 4" are the column numbers corresponding to group1 and group2 respectively. The column numbers are separated by commas. Users can define the column number according to their own sample number.
>
>In output file compare_merge_celltype.txt, the Ms is the average of group2 minus the average of group1, and pvalue is the p value of the permutation test. Users can also compare interested cell pairs in the merge_celltype folder.
>

If you have any questions, you can send Email to <che@whu.edu.cn>
