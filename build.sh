#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEX_FILE="$SCRIPT_DIR/resume.tex"
OUTPUT_DIR="$SCRIPT_DIR/output/latex"
PDF_FILE="$OUTPUT_DIR/resume.pdf"
cd "$SCRIPT_DIR"
mkdir -p "$OUTPUT_DIR"

#-------------------------------------------------------------------------------
# Check dependencies
#-------------------------------------------------------------------------------

# required system packages and their corresponding .sty / binary checks
# format: "pkg_name:check_type:check_target"
# check_type = "sty" (kpsewhich) or "bin" (command -v)
REQUIRED_DEPS=(
    "texlive-xetex:bin:xelatex"
    "texlive-latex-recommended:sty:fancyhdr.sty"
    "texlive-latex-extra:sty:moresize.sty"
    "texlive-latex-extra:sty:paracol.sty"
    "texlive-fonts-recommended:sty:pzdr.tfm"
    "texlive-pictures:sty:tikz.sty"
    "texlive-fonts-extra:sty:raleway.sty"
    "texlive-fonts-extra:sty:fontawesome5.sty"
    "texlive-lang-chinese:sty:ctex.sty"
)

MISSING_PKGS=()

for dep in "${REQUIRED_DEPS[@]}"; do
    IFS=":" read -r pkg check_type target <<< "$dep"
    ok=false
    case "$check_type" in
        bin)  command -v "$target" &>/dev/null && ok=true ;;
        sty)  kpsewhich "$target" &>/dev/null && ok=true ;;
    esac
    if ! $ok && [[ ! " ${MISSING_PKGS[*]:-} " =~ " $pkg " ]]; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
    echo "=== Missing system packages: ${MISSING_PKGS[*]} ==="
    if command -v apt-get &>/dev/null; then
        echo "=== Installing via apt-get ==="
        sudo apt-get update -qq
        sudo apt-get install -y -qq --no-install-recommends "${MISSING_PKGS[@]}"
    else
        echo "ERROR: apt-get not found. Please install manually: ${MISSING_PKGS[*]}"
        exit 1
    fi
fi

#-------------------------------------------------------------------------------
# Compile (two passes to resolve any cross-refs)
#-------------------------------------------------------------------------------
echo "=== Compiling (pass 1/2) ==="
xelatex -interaction=nonstopmode -halt-on-error -output-directory="$OUTPUT_DIR" "$TEX_FILE"

echo "=== Compiling (pass 2/2) ==="
xelatex -interaction=nonstopmode -halt-on-error -output-directory="$OUTPUT_DIR" "$TEX_FILE"

#-------------------------------------------------------------------------------
# Cleanup aux files
#-------------------------------------------------------------------------------
echo "=== Cleaning up ==="
rm -f "$OUTPUT_DIR"/resume.{aux,log,out,synctex.gz}

echo "=== Done: $PDF_FILE ==="
