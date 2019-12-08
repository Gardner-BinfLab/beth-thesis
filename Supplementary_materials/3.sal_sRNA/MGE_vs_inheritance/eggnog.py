import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
#%matplotlib inline
#config InlineBackend.figure_formats = ['svg']

df = pd.read_csv("eggnog_ratios_vertical_vs_horizontal_only.csv",sep=",")
df.head()
plt.figure(figsize=(7,7))
plot=sns.scatterplot(x='percentage',y='Total_annotations',hue='Inheritance_type',data=df,s=30)
plot.set_title("Eggnog functional annotations vs inheritance type")
plot.set(xlabel='% proteins annotated as MGE-like', ylabel='Total flanking protein annotations')
plt.show()
plt.savefig("eggnog.svg", format="svg")
