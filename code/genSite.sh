#!/bin/bash

# echo Updating the Docs for Aries RFCs

# Clean out the docs folder
rm -rf docs/*
mkdir -p docs

# Root folder -- README.md
cp -r contributing.md github-issues.md MAINTAINERS.md README.md SECURITY.md tags.md 0000*.md *.png collateral docs
cp LICENSE docs/LICENSE.md
sed -e "s#/tags.md#tags.md#g" index.md > docs/RFCindex.md

# Features and Concept -- collect all of the RFCs
cp -r features concepts docs

# Make a copy of AIP 2 RFCs using the right commit for each
python code/aipUpdates.py -v 2.0 -l "./code/cpAIPs.sh" | \
   sed -e "/0317-please-ack/d" -e "/0587-encryption-envelope-v2/d" -e "/0627-static-peer-dids/d" \
   > copy_aip.sh
source copy_aip.sh
rm copy_aip.sh

# Cleanup the links in the RFCs
for i in docs/features/*/README.md docs/concepts/*/README.md docs/aip2/*/README.md; do 
   sed \
     -e 's#(/#(../../#g' \
     -e 's#index.md#RFCindex.md#' \
     $i >$i.tmp
   mv $i.tmp $i
done

# Remove the existing AIP and By Status Links -- we'll add them back
MKDOCS=mkdocs.yml
MKDOCSTMP=${MKDOCS}.tmp
MKDOCSIDX=mkdocs_index.yml

# Strip off the old navigation
sed '/RFCs by AIP and Status/,$d' ${MKDOCS} >${MKDOCSTMP}

# Add back in the marker
echo '# RFCs by AIP and Status' >>${MKDOCSTMP}

# Navigation for AIP 2.0 files
echo "- AIP 2.0:" >>${MKDOCSTMP}
for i in docs/aip2/*/README.md ; do head -n 1 $i | sed -e "s/# /    - /" -e "s/: / /" -e "s#\$#: $i#" -e "s#docs/##"; done >>${MKDOCSTMP}

# Navigation for all RFCs by Status
python code/generate_mkdocs_index.py
cat ${MKDOCSIDX} | sed "s# : concepts/0799#0799 Long Term Support: concepts/0799#" >>${MKDOCSTMP}
rm ${MKDOCSIDX}

mv ${MKDOCSTMP} ${MKDOCS}