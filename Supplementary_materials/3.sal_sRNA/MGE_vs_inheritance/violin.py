#!/home/beth/inst/anaconda3/bin/python

import pandas
import seaborn
import matplotlib.pyplot as plt

df = pandas.read_csv("all.csv")
inheritance= pandas.read_csv("inheritance_2.tsv",sep="\t")
inheritance.columns=['sRNA','Inheritance type']
df = pandas.merge(df,inheritance,on='sRNA')
df['Ratio'] = df['Total_annotations']/(df['Total_annotations']+df['Missing_in'])

#plot = seaborn.violinplot(x='Inheritance type',y='Ratio',data=df,cut=0)
plot = seaborn.boxplot(x='Inheritance type',y='Ratio',data=df)
plot = seaborn.swarmplot(x='Inheritance type',y='Ratio',data=df,color='.25')
plt.show()
