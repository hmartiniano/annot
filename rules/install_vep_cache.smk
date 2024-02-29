rule install_vep_cache:
  output: touch(".vep") 
  shell:
    "vep_install -a cfp -y GRCh38 -s homo_sapiens -g all -t -d {VEP_CACHE_DIR}"
