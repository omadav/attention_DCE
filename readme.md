Project Title: Attentional Offloading and Dynamic Preference Construction in Overtrained Choice Environments

Manuscript workflow

This repository is now organized for a GitHub-to-Overleaf LaTeX workflow.

Core files:

- `main.tex`: Overleaf entry point.
- `sections/`: manuscript text split by section.
- `fig/`: figures and images referenced from LaTeX.
- `bib/references.bib`: BibTeX database.
- `tables/`: generated or hand-edited table files.
- `scripts/convert_docx_to_latex.sh`: helper for converting a Word draft into LaTeX with `pandoc`.

To convert a Word draft after adding it to the repository:

```bash
scripts/convert_docx_to_latex.sh path/to/draft.docx
```

The script writes the converted text to `sections/00_converted_from_word.tex` and extracts embedded Word media to `fig/word_media/`. Review that converted file, then move the cleaned text into the numbered section files.

To compile locally:

```bash
latexmk -pdf main.tex
```

1. Research Question & Core ProblemTraditional Discrete Choice Experiments (DCE) and Random Utility Models (RUM) operate under a static behavioral assumption: whether an agent makes their 1st or 150th choice, they are assumed to be in a perpetual, goal-directed state—actively scanning all attributes, calculating trade-offs, and experiencing varying levels of cognitive noise (often adjusted via the scale parameter $\lambda$).This project challenges that paradigm by merging cognitive learning mechanics (overtraining) with structural econometrics to answer two core questions:The Attentional Mechanism: How does overtraining in a stable visual choice environment cause a structural shift from active compensatory evaluation to spatial heuristic adoption (choice inertia)?The Preference Impermanence: How does this attentional offloading dynamically alter a consumer's underlying Willingness-to-Pay (WTP) for primary vs. secondary attributes when environmental predictability is disrupted?

2. The Econometric Machinery & The Endogeneity ProblemStandard choice software (e.g., Apollo) treats choice persistence/inertia as a static baseline parameter. We prove that this creates a fundamental Omitted Variable Bias leading to Endogeneity (Visualized in image_104f80.jpg).The True Model:When choice inertia is explicitly modulated by a participant's hidden cognitive state (Latent Attention):$$U_{n,t} = V(X_t, \beta) + \beta_{Inertia, 0} \cdot I_{n,t} + \beta_{Att} \cdot LatAttention_{n,t} \cdot I_{n,t} + \epsilon_{n,t}$$Where Latent Attention is mapped to physical eye-tracking data via a structural measurement equation of visual gaze entropy:$$Entropy_{n,t} = f(LatAttention_{n,t}) + \varepsilon_n$$And the true operational inertia parameter updates dynamically:$$\beta_{Inertia, n, t} = \beta_{Inertia, 0} + \beta_{Inertia-Attention, n} \cdot LatAttention_{n,t}$$The "Model without Attention" Failure:Standard approaches omit the latent attention interaction, forcing it into the unobserved error term:$$\hat{\epsilon}_{n,t} = \beta_{Att} \cdot LatAttention_{n,t} \cdot I_{n,t} + \epsilon_{n,t}$$Because a participant’s decision to rely on the spatial anchor ($I_{n,t}$) is highly correlated with their attentional withdrawal ($LatAttention_{n,t}$), the regressor becomes correlated with the error term:$$Cov(I_{n,t}, \hat{\epsilon}_{n,t}) \neq 0$$Result: Standard RUM models suffer from severe observational equivalence. They cannot distinguish a blind habit from a calculated choice, causing the aggregate inertia parameters to lose statistical significance and wash out in the noise. Our model resolves this endogeneity using eye-tracking as a definitive mathematical tie-breaker (image_104f80.jpg, image_104fb8.jpg).

3. Main Empirical FindingsFinding 1: The Overtraining Fan & Cognitive ProfilesBy running a $K$-means clustering analysis on participants' Response Times (RT) and standard deviations (image_888581.png), we discovered clear behavioral heterogeneity:Heuristic Adopters (Cluster 1 - Red): Rapidly compress their RT (~10s) and variance. They lock onto the spatial layout immediately, keeping their median trial duration flat across the entire timeline (image_888561.jpg).Compensatory Deliberators (Cluster 2 - Green): Maintain high RTs and massive variance. They resist the habit, trying to evaluate all trade-offs continuously, but are eventually worn down by overtraining by trial 100.The Structural Fix: Modeling $\beta_{Inertia-Attention}$ over the entire sample reveals that for the vast majority (Orange density mass in image_104f9b.jpg), pulling attention away directly constructs and rockets the behavior inertia up (image_26730b.jpg).Finding 2: Attention Limits Dictate the HabitWhen splitting participants by the median of their latent attention (image_267023.jpg), the proof is absolute:High Attention Group (Teal): Keep their choice inertia completely flat and stable over time. Time on the task alone does not create a habit.Low Attention Group (Red): Experience an exponential explosion in choice inertia. The spatial heuristic is strictly a function of dropping attention.Finding 3: Dynamic Preference Re-weighting (WTP Is Not Static)The joint in-lab and online model reveals a major discovery regarding Willingness-to-Pay (image_267369.jpg):Visual Fluency Drift (Trials 1–100): As the task becomes familiar, consumers don't just get faster—their relative valuation changes. WTP for secondary attributes like $CO_2$ and Comfort increases relative to cost. Visual predictability makes evaluating these traits cheap.The Environmental Shock (Trial 101): The moment the spatial layout is scrambled, forcing participants back into active visual search, preferences instantly re-weight. $WTP_{CO2}$ plummets and $WTP_{Comfort}$ collapses toward zero. Facing visual uncertainty, consumer choice instantly regresses to a highly price-sensitive, cost-dominant baseline.

4. Target Manuscript Repository StructurePlaintext├── data/
│   ├── raw_in_lab/           # Raw eye-tracking & choice data
│   └── raw_online/           # Online choice data matrix
├── models/
│   ├── apollo_baseline.R     # Standard RUM without attention (endogenous)
│   ├── apollo_latent_att.R   # Latent attention model equations
│   └── kmeans_clustering.R   # Cluster scripts for RT/SD profiles
├── figures/
│   ├── image_888581.png      # K-means scatter plot (RT vs SD)
│   ├── image_888561.jpg      # Time-series duration by cluster
│   ├── image_267369.jpg      # Latent attention, Betas, and WTP trajectories
│   ├── image_26730b.jpg      # Individual individual-level inertia fans
│   └── image_267023.jpg      # Inertia growth split by median attention threshold
└── manuscript/
    ├── sections/             # Drafted chapters
    └── main.tex              # Overleaf Master LaTeX file
