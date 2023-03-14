---
title: How robust are crosssectional psychological networks? A comprehensive Bayesian Re-Analysis
---

Network analysis has become extremely popular across the psychological disciplines, especially in clinical psychology.  Along with the enthusiasm for networks, there has been growing concerns about the stability of their results. In interpreting results and accumulating our understanding across studies, we need to be aware of the potential uncertainty underlying the estimated networks. 

In this project, our goal is to assess the robustness of published psychology networks. We will re-analyze previously published networks and address questions such as: Is there evidence of conditional independence when an edge is missing from a network, or is the edge simply too unstable to be included? Also, how much evidence do we have for the inclusion of edges? To adequately assess the robustness of the networks, we will use a Bayesian approach. This approach allows to quantify the uncertainty of the networks (Huth et al., 2023)[^1]; in particular, determine the uncertainty of the estimated network structure, obtain the statistical evidence for edge inclusion or exclusion, and quantify the precision of the network parameters. 

The project will involve a large-scale search, acquisition of datasets, and re-analysis of published cross-sectional networks. Therefore, we are looking for datasets that have been used to publish a cross-sectional network.

Interested in sharing your data? Please fill out this [form](https://forms.gle/iLmBNNbfSgqt2SXU9). We will contact you.

In case you are looking for more information, feel free to email us: networkreanalysis@gmail.com

[^1]: Huth, K., de Ron, J., Luigjes, J., Goudriaan, A., Mohammadi, R., van Holst, R., Wagenmakers, E.J., & Marsman, M. (2023). Bayesian Analysis of Cross-sectional Networks: A Tutorial in R and JASP. PsyArxiv https://doi.org/10.31234/osf.io/ub5tc

## FAQ:

<details>
<summary>What requirements does the dataset need to meet?</summary>
<br>
We are looking for datasets that have been used to publish a cross-sectional network in psychology. The network model needs to have either been estimated as a Gaussian graphical model (GGM; continuous data and sometimes also used to analyze ordinal data), Ising model (binary data), or Mixed graphical model (MGM; mixed data). Networks estimated as MGMs should not contain unordered categorical nodes (e.g., type of medication, practised religion), but only a mix of continuous, ordinal and binary data.  The variables in the network should have been obtained through psychometric scales rather than biological measurements. Authors need to have obtained ethics approval for the data collection and informed consent by participants.

<details>
<summary>How will the datasets be transferred and stored?</summary>
<br>
Once we have approved the dataset, we will send you a link to our data storage service – Research Drive. On this ISO/IEC27001 certified system developed by SURFSara data is stored encrypted and can only be accessed through 2-Factor Authentication. The dataset will stay on the server and only be loaded into R to analyse it.

<details>
<summary>What form should the dataset be in before the transferring?</summary>
<br>
We would like to receive the same data that was used in the final publication, preferably already fully cleaned and containing only variables that were also used as nodes in the network. Missings can remain in the dataset, if they were also imputed for the published network. To avoid any data security issues, we ask for fully anonymized data and consider it the responsibility of the data sharer to ensure that this is the case.

<details>
<summary>What information will you extract from the dataset?</summary>
<br>
We will re-analyse the dataset in a frequentist and Bayesian approach and will extract the interaction estimates, the evidence for inclusion of each edge, and the posterior credible intervals. We will also extract meta-data that we can find in your publication such as node size, sample size, research area (e.g., psychopathology), and construct assessed (e.g., depression). 

<details>
<summary>What will be shown of my dataset in the final publication?</summary>
<br>
The network results will be summarized and evaluated on an aggregated level across all datasets. We will show and discuss the results divided by the type of model (e.g., Ising model or Gaussian graphical model). The final paper will conclude how stable networks are in general; we will not deep-dive into any individual network and discuss its results. We will upload aggregated information (i.e., parameter estimates, posterior edge inclusion probabilities, credible intervals) and the meta-data to the Open Science Framework. We will not share any raw, individual-level data.

<details>
<summary>Who is conducting the research and how is the project funded? </summary>
<br>
The project is conducted at the University of Amsterdam in the Psychological Methods department through Karoline Huth, Jonas Haslbeck, and Maarten Marsman. The project is funded, in part, through a grant by the European Union (ERC, BAYESIAN P-NETS, #101040876) awarded to Maarten Marsman, and the [Centre for Urban mental health](https://www.centreforurbanmentalhealth.com/) project awarded to Ruth van Holst and Maarten Marsman. 

The Centre for Urban Mental Health is the largest Research Priority Area (RPA) of the University of Amsterdam (UvA) and comprises 3 faculties: Faculty for Social & Behavioural Science (FMG), Faculty of Science (FNWI), and the Faculty of Medicine (AMC). The aim of this RPA is to find new pathways to target with intervention to promote urban mental health, using a complexity science approach.


