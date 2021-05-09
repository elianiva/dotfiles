#!/bin/bash

case $(uname) in
 Darwin)
     echo "Not supported"
     exit
	;;
esac

SCRIPT=`realpath $0`

readonly BASH_BINARY="$(which bash)"
declare -x UEBERZUG_FIFO="$(mktemp --dry-run --suffix "vimg-$$-ueberzug")"
declare -x PREVIEW_ID="preview"

declare -x TMP_FOLDER="/tmp/vimg"
mkdir -p $TMP_FOLDER

function start_ueberzug {
    mkfifo "${UEBERZUG_FIFO}"

    tail --follow "$UEBERZUG_FIFO" | ueberzug layer --silent --parser bash &
}

function finalise {
    3>&- \
        exec
    &>/dev/null \
        rm "${UEBERZUG_FIFO}"
    &>/dev/null \
        kill $(jobs -p)
}


function draw_preview {
    x=$3
    y=$4
    width=$5
    height=$6
    echo $@

    if [[ "$1" == "imagepreview" ]]; then
        >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
            [action]=add [identifier]="${PREVIEW_ID}" \
            [x]="$x" [y]="$y" \
            [width]="${width}" [height]="${height}" \
            [path]="${2}")

    elif [[ "$1" == "videopreview" ]]; then
        path="${2##*/}"
        echo -e "Loading preview..\nFile: $path"
        ffmpegthumbnailer -i "${PWD}/${path}" -o "${TMP_FOLDER}/${path}.png" -s 0 -q 10
        >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
            [action]=add [identifier]="${PREVIEW_ID}" \
            [x]="${3}" [y]="${4}" \
            [width]="${5}" [height]="${6}" \
            [path]="${TMP_FOLDER}/${path}.png")

    elif [[ "$1" == "pdfpreview" ]]; then
        path="${2##*/}"
        echo -e "Loading preview..\nFile: $path"
        [[ ! -f "${TMP_FOLDER}/${path}.png" ]] && pdftoppm -png -singlefile "$path" "${TMP_FOLDER}/${path}"
        >"${UEBERZUG_FIFO}" declare -A -p cmd=( \
            [action]=add [identifier]="${PREVIEW_ID}" \
            [x]="${3}" [y]="${4}" \ [width]="${5}" [height]="${6}" \ [path]="${TMP_FOLDER}/${path}.png")

    fi
}


function parse_options {
    extension="${1##*.}"
    case $extension in
    jpg | png | webp)
        draw_preview  imagepreview $1 $2 $3 $4 $5
    ;;

    avi | mp4 | wmv | dat | 3gp | ogv | mkv | mpg | mpeg | vob |  m2v | mov | webm | mts | m4v | rm  | qt | divx)
        draw_preview  videopreview $1 $2 $3 $4 $5
    ;;

    pdf)
        draw_preview  pdfpreview $1 $2 $3 $4 $5
    ;;

    *)
    echo -n "unknown file $1"
    ;;
    esac
}


# if [[ "$6" == run  ]]; then
#     UEBERZUG_FIFO=$7
#     parse_options "${@}"
#     read
# elif [[ "$#" == "5" ]]; then
#         trap finalise EXIT
#         start_ueberzug
#         SHELL="${SCRIPT} ${@} run ${UEBERZUG_FIFO}"
#         $SHELL
# else
#     echo "not enough argument"
# fi


trap finalise EXIT
start_ueberzug
parse_options "${@}"
read
