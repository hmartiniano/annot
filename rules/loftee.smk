# vim :set ts=4 sw=4 sts=4 et :

rule download_loftee:
  input: ".vep"
	output: touch(".loftee_plugin")
	shell:
		"git clone --single-branch --branch grch38 https://github.com/konradjk/loftee.git annotations/loftee"

rule install_loftee:
  input: ".loftee_plugin"
	output: touch(".loftee")
	shell:
		"cp -r annotations/loftee/* {VEP_PLUGIN_DIR}"


rule download_loftee_data:
	input: ".loftee"
	output: protected(LOFTEE_DATA + "/human_ancestor.fa.gz"), 
		protected(LOFTEE_DATA + "/loftee.sql"),
		protected(LOFTEE_DATA + "/gerp_conservation_scores.homo_sapiens.GRCh38.bw")
	shell: 
		" cd {LOFTEE_DATA} && "
		" wget -nc https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/ -r -nd &&"
		" rm index.html* *gif &&"
		" gunzip loftee.sql"

