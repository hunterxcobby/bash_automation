#!/bin/sh
# This script was generated using Makeself 2.4.5
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="1257690964"
MD5="feeb24e6ad960e7977d8fc6b9ffe686b"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
SIGNATURE=""
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="My Script Installer"
script="./run.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=''
targetdir="makeself-7089-20231207002834"
filesizes="117486"
totalsize="117486"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="713"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  PAGER=${PAGER:=more}
  if test x"$licensetxt" != x; then
    PAGER_PATH=`exec <&- 2>&-; which $PAGER || command -v $PAGER || type $PAGER`
    if test -x "$PAGER_PATH"; then
      echo "$licensetxt" | $PAGER
    else
      echo "$licensetxt"
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=0 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.5
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive
  $0 --verify-sig key Verify signature agains a provided key id

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Verify_Sig()
{
    GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
    test -x "$GPG_PATH" || GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    test -x "$MKTEMP_PATH" || MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
	offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    temp_sig=`mktemp -t XXXXX`
    echo $SIGNATURE | base64 --decode > "$temp_sig"
    gpg_output=`MS_dd "$1" $offset $totalsize | LC_ALL=C "$GPG_PATH" --verify "$temp_sig" - 2>&1`
    gpg_res=$?
    rm -f "$temp_sig"
    if test $gpg_res -eq 0 && test `echo $gpg_output | grep -c Good` -eq 1; then
        if test `echo $gpg_output | grep -c $sig_key` -eq 1; then
            test x"$quiet" = xn && echo "GPG signature is good" >&2
        else
            echo "GPG Signature key does not match" >&2
            exit 2
        fi
    else
        test x"$quiet" = xn && echo "GPG signature failed to verify" >&2
        exit 2
    fi
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    fsize=`cat "$1" | wc -c | tr -d " "`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." >&2; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. >&2; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=
sig_key=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 180 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Thu Dec  7 00:28:34 GMT 2023
	echo Built with Makeself version 2.4.5
	echo Build command was: "/usr/bin/makeself \\
    \".\" \\
    \"runthis.sh\" \\
    \"My Script Installer\" \\
    \"./run.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\"makeself-7089-20231207002834\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	arg1="$2"
    shift 2 || { MS_Help; exit 1; }
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --verify-sig)
    sig_key="$2"
    shift 2 || { MS_Help; exit 1; }
    MS_Verify_Sig "$0"
    ;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    shift 2 || { MS_Help; exit 1; }
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
    shift 2 || { MS_Help; exit 1; }
	;;
    --cleanup-args)
    cleanupargs="$2"
    shift 2 || { MS_Help; exit 1; }
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 180 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 180; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (180 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
� �qe�\{w۶�Ͽ�@m%��z%��ʑ��IZߦvN���"!�
���߄����+�k������ȍbubUb5���D�b�3���XC((�cU�~ a���[�ʪ�d�_�2��-�&2���sO&Jg͎0�L���؟��
�����L}-��E��5�D{�{U�Ժ��j��F�+ݖ�y��K�Og�'--g�@}��o��֊�oo�����*>7�i���uӺ)�B��U���m��=8��8}1SZK���|�B1Z �B��8�fBEf�5n�@Ϧ��(
�"Ri��`H��d�,�%��=u�Jҹ�c���]�� s��e��pl	������"��mAԒ獰�9	[|�-N���o�������V��D�/F�l�����Z����ow���k����4Z՚�l�Q���'�L�I�h��Dc��$S�����b�z/� q	b|
^ ���K�Eap�7�����h���A���<!�S*ω�c��!����u��if^L@��'|OI|>Q��e�����C(9�S0���3HH3a�ph�O�0���X���lx������?8x&�	
C53�U:��G����f3�����HTN6��۫5�ϷV�X���'�
�o�:��R��XϢ�y��9��g����n��������f���sU���|�\Łe���$��d�~?�q������~�p��ގ�^ᇉ��h /�*A�zV�KW��C�v���i\�������<W`s�\x*Qn� �P��{ L�?��=�^�,�R��J�U��n'�B�D"� \��� �\C���(
@�<�b�D-�V��Z0� ���*��$� ���M��j{���
��ri-��;�z~\o�p�X%��w���t�&;�:�r�ש.�_O���}�cU�V����0v��p�����{>~�\���LCw:��X��H�<G��i$�gC�$����}]̝�)�^��
6�a�t$���}����)�{K_���ϑ�9
�X�ex�W���AO�CJ7�+��\γ��M#�@Q�I��Ma���)���-�a#W`�~H5t��O��?mz���1�c�C����cM=�ьX���geZ��!�?��;���~T�����_�P;���"2�ځ�Q�Q1_��g)�����v{ǘ�CH�9hm6�}�Q���.��T>`.�W�o��� cH�0g���E�8��rAN�����I�9΁�-m�~�����C��}��)j�̝� c#"�$Y@[A��I3����������� �z?$�b�� �	\88S50O�	�QK�5z��א�Le8�}�:.R���"
�D�F
�L�X�*t���zCsV�q�C�'��ir/6����66��YdmdK��ܓ�s,Z���u�
�1�#�3Ncx���.��T� 0*G$��w�u�5E�)�
�2�e��@�s�z/RؑY��q�HM[h��c��#�0�W��6���>�+3X��w2;�=���y��V1�K'�5�d^����Rd�q�j	h�g`�ad���q�A��u����(~!��ŵ���G�� :�,�?$�o��l�(Ƚ73�9mZyǰ�a�A0@O�Mda�]�!�1�K�˳vj��?
NM��� H�-.Qom40�@�4|�
M�2���!\G��4���O�
�8L�T(Y�b�	�B��P����[�&��~Y��#��;�`L�w�������r$t��'�f&�7+	���?��T�LYY�):�h�?�Z�'���m���\�eKm�'?b-%��f�:䃭�O�f`ws�ZI۲ز�(����=��^����br�5-eZ��o���T�w��Zj�H���q����r.T ���$���[�O�}א</����׻����9@��v�97 ?�����\���^����������s�WK��Icʇ~
�x�l($C�E3���ǒ�mp�O�G�V1���8�F��m��r�#Wv�gk��~��wm�%����q�{��<�� 3���������<��(�d
��L�#N������<9��I���O;���߈�
����n�Z?�s}������
���^?��?.A ��1�L ��e�̍P���m{��A z��v-6�*r"�P'lb��k�������2�����X����y��-�h��r��C�T�+�$�2�a�}����E��0��`"��{���O��B:�O�T�<M/p�,�}�v}�nv~'Y��`E�\k�qYx��zV*��ăܹ�a]w����Ƒ�b���!֌pj��*�r�<�|�"�w0.=}�dj�g�HI<��i+'����*Ad�q����=����-�!�=�@�b�z����T��Mq!�Ԭ��x 6P�#��%��X}�Q��8�GE8��&��B��(� G��4��IlX�5s��X5E�Oj������&�wˑ��F�x��Zt;5-��I�h���e*H�u�!�a l��L��` �{�R��3��'!�3 �ZV���)�㸒j���k��~
ߣ�{�
	D�2�#$�ٙ� �a1	q����j���Y�n����)V���.љـ�D���/��`/�H�
�c�G� �<��.��q ��l�B�(�v�� �;E����Q��o�Oj�֩A�"��QIO�̇0Y�f�<(=4��Sˋhc���T��|Y9�!ɢ��A��a�&<�C�O������&��L�_@h���"��p��w�2?���C�Q���:�Nh�|� ���`�]��L�͇�1���3$��)�U��G�
�Ls�:�=�n��ͲےeQ�w쇔t��T�El��c�6��䊸�d�=�X_a�����
�]�kk������C����?�&��6�a[M����_i�Gb`g&�(�����s_�!�`2��f;�F��Fe��j�[4jR]+�g��
t�Ӆ��Bd3��c��1l>��K���ߵ薯��L�$��Z$0P����U� L&EV�#Ӭt9CGm��8D�\��]2��!��*|��1 �H��_r���_s�p~��K�l�"��	-�bfv@�	�7�R�|6f]Rl����s��`��.%��T���s�FC�K����Tk��Q7辞�;,1`�{�����x��O��1�s�j�ɯ��K���VW⃃��L�F�%��G+��a-B���edª��.C�t������#[�ʟZ�,"5qb��0���r�X(he�~,��6�gyJQ�;�G�����L�]����&[�f_(
�� dŃsk��-��'F����
���,��xS�(�s����ސ.Ô�2�E�XMR�~���8��kn��1�3�1h�o��Q���)��F�q�gC���ρ!�f��a���Ff�x�EF�e (��
 ]�նW
�K�I�>B��,��{�,�s%��]YV����8MS�3-j�25�h�hYc��Q�5���t���=�n�qy��52�ڑŕ;�ʘ���8œ	��|�1��D/��\m�g
��k���b�L����J(�m��'�w���Vk�+���Ib��9V2ð���M���b�B���$�뜙����%�?uv���Lň
��		�F�[�X�
/��%8PЭ,0e<�,�c�sن2m0�Ծ�ň��xEr)	��-$( 
X0���ޕ�EU�}\����[�(ξ0,��+J��Н�;0�3�̨�i������k�����Kf����Z�[Zj�VZZ)�f���s�ܙ�����5S#�p�s��<��J"�wZU���ғ@�a�Q)8�13'
���7=����Jz*����J�,�	o�Xm!��wՔ}o3jMx3I�%U���5¯���	1٫$-���I^��,�g!�{^"I��) �'c=͛�V�������	4���<�	��$\'	ױ��6�W᪁�h]����τü�W0�`!���Iq?ɸU� �����s>\���ɴ=�  ��H�L��P&$p�9�$ɯ�L~H��ĺ�W���"��� �wRYp	�G�U����GhM�f��=�F�?�C+��J;!�>���L�fV(�ſ�Y�$����g��F����W�߿T�i�"q�a<`��b[+_
.�>�ic�2��l�@D�����
d=����F��7�O�6��_������:�W/�Ww�oQN�t�ErΣ���А�0�ҷ�H|5�c#@�.,����VOm�M��@�sM�ErI�x9HXT��]E>dG�`EJvs��t ׃��Q@
�T�߃_Pi������ٱ����TJ�\.��?5�ə��x:��,PsEQ�8���[)�vF,""\Z��;_��G��Hy��-apn
�[O����' ���(��⎁ǀ�л��$r�/�g��X�uԕ�3j�9�NXe��&oH,D��h�9��E�G�����;;��p
�C
 ��A�ڕIH`��
@
��
ј6�-�r��<0q5K�x�ȼ�[Jx^�;,�hMQ[��
e�I��5��>�Rf���X�p9H"����7�t~��u ����KjY>�W��Hq�"�����q��Z�}�!��(� ���ܰf���� �L�B�ʡ���E:e`o�'��X�Ej����Eq:.���C�1�/6��%ʛC,��(��M"-�,���6�P	���۾v��c�T�T�+��w�I�+��K���� �_�4+��
=aq�<�ڋ0�%������% �-�@���T^��b���D���EبJ&O�3\4��΍�/�#�]��T�o���$^p���
��J�A��"9�gCr_<Ka��-<�~!�}t$>ZT�S��-�^W�cO�>���6�#�n6�g�y���s���,�x�E�H�h0x���C��Ɍ���I�XW
��_�� dV��;�(<�'Zh�Ab{D������|9(�	X��B,7��y���k�#<�ײ���H�p\��[��~�����{V� �HM]�HlϬE�'�p3�1$+Ǿ��ЪZ����
�!���y�$`��4G�� P�E�m�3�Q���+N�vX���6����P1���Z��8j���n����:�7|v'��3�g$���ix�1n����T���E<�Ĺ�stsE~Bp���C-��
G��P�m�Tn@"�Ʃ_H���G2�
�zF����Ռ�4Dvհ�L� �X�ˑm�
�E��붛�eҎݡ����מ�LN�w�7n\�ݘ���.>l�;�݃H)�K)/��
����~`N����/�0,5[�-10�y�����$��NbX'�?<��;��mB��
e�+5�X��|���c��,��;B�|�9ne��ƹj�A����O�V��g�OD���	�j �:�9�^�a��a �45�M�F�A��H�IH�8&%-=sXv����lPĲ���'�u�' �g��h=Pt�жb�^3T����E�3��E�8���봆խ�Э/��$j��MB-�P��c���e
�Q����{�ڂ�LE��ylu���5���.
�d"ly��Rfd<#ʩ����Z�8��c.
�_�f�G�i�F��1D�2>}KT{.����F1�)d ��Ť�j^E|� �0ӽ���x��A�(���$�~z���A P*��l-�P�伐�Z�?�M5�Pc��Ҽ=D@���w�������v
�����L�/�S���W&�*8�n(U��b]�$n�]�u��/���B�|'�-|��i�i��-�����H��d�h�D�۫�	��U�' x�!6�IY�񴜅V?��BĕX�'
'����z�R�lHԞ����8$G�nd{Ⱥ�SBVL�Mֺ����\�w1�;�4�w_ţh���D�?SLw�@�'9�l-�F_%B�"'G�jv,
�
����Q����d\����K�Ȗ�綐}5'�w~w�ݜ�{5^"q���
=�W��#&�z�b�>���IG��&� 8��
m96�=�	j��5�������� ������b����k������r <��}��BO��Gi"�ar�O�'QGN�F�ҫ�1&�6�ͪ�V3k��f5g��j9��Ͳ&�>��[���k���:��_o� �����^^,Ϻj8��WU���[���q�fJ�F?��yE~���u��_�n����6�|����vKL�:�%�O䬤���φw������������K��ک;1�����鐕�f��0bR�q��G��>�`��Is4�
7��ƴ	�:��~bF�����
[2S���"��B��͝Ӿ4�a����Lz=?���G��ڷ�������R|���[��_�`q|�5�n�?�=g�9��8r|g�gv]���Q���I�:��|�i�?���n��ڶ���PC��e~mw��͆O�]j���i�������}_�3#���Ȍ�!�.]�֬ݹ��e���K��Z�Y���}&��_��������ߜ��˙Yo��l��Y����;mv��7&{y��/*�
�;�S�� �������{W��].HW�Op9���vZA(�@���F���߭:˗��s��sS���5G�
�[�K�����H����K��	`��^DJ������
b����E�b�IFA9;@JKC����$"�p��̝�͍�����L8�ã�*����G&3L;&x�Y��O��j�0�j$��Ǵ���J�ݹ#ȇ�d��|���d���Z��Ң�R��WF� U�C��P��|�U��R��(�eP�����wA>��\�����q(��F}7����)��N�.p��Z=�y�H�=�����?
�鐋*2���ygLMjx�����jM'�&��J�5�N��63�k�J L�� �g�@7i��Q&^B^K��8��o��E
	�i�9�C Tv �R<qa��j,�w����ǿBѫ��k�P�-��Ԧ�=�	���<
��lK�c�i&��(�<�<��P�u�-r���h^u$Z!�5I������(t�u|��ʹ�"�u�R'ꢩ�;o��1$�~D͎
uTf�cBNa�˦��H�$���������Ah6��ƾ�s��B�i� ��������_�A�
�j�e�J~Y"2�
�����
6���2�<(-	��E���6T'1���\��������$y���r��$=�	�l����R�71$�=�#�L��rV�h���	�b�����	R�j0�����yT�jhv�s�Fg���L���@N7&�����}%�H�a..�7"^�b[�d� Y�3�Jl�h�2���X�j�`������ꐿ��P�Í� ` ��T���*�E!����g1�?X50=b3��2{`����QP���"����~��a����y!a6�Cg��M�eL�*E��c&�V��?}�䶂Y��^Ȟ)?*�Bl�8EK
Zx��ݰhj��߀v�����=��3�V��Z�J�w�g�zF���f��I2���_;�k2�o����;h�����Ǽ����x�(��Wd�w�$�l��$�	[�76D�f Y6#��j�M�y�B�/W�Kr�h:f]W������+�9Z�w�N�ʶ`rL��ڃy�))�NL.h��c-��$�>�^.,�e�������X2`t��\���>(r�5tՀS�6ޥi��IV�C/uV#8�4)�!!k��\�O���y:$���Tj.���ވ�k������<#��)�JW,���s�p�Q�d�P%}�]� R��3�_HZ���A����!Hm��v�q��o�1�Rd��E� Ē�D%��b����/�/h������y�ga�l8{k�H���|v�����#3��'����cMU��.�P	e�q(���D��_RVw�¤|숵'���V��E��2�C���48�C���2L�i����bԀ��e>�j	g�	v趶vȚ螃K'�����Re�=ZN�$�?���d��'�ͫ]����Bq�-I�W��h^��H��vf+���c[����3��|g�ܔ�_F�AtF�A���@3�.�t���Rz�d����z�#$u��
�ڥ�2���Zȱ�4Ӱ�b@�R�o+�!ˈ�p�����)@.@�P�`�n(��z
b�C>D~p����BYX{	����c�d7C�dPBB�� ����=�������ƱI��¶[�ҦL����
D�N�Ɔ���.�����j���tCfv��_�Q�Su��T�O)�FD�^Ywd���E<�����+lv{e�ѥ]W��˸��$a����8��_ʙ���P海4�j�UOG�F�gZ���y���!���폆��E"$]��J��:}����y��ߺ�'"����؛P�
�Gh�*�*`뤐V*h�p�/d���LpFA�7��\_���}G.��rg��ƖX0ZZCg�tzc�e\�`o�����K�l�p
�!e�jߎ�����TלV�0T�/�6퉈����m{��}k�	>�)Q��w��2?
*K������Y����Z�Q��1����.�T�'�T�l˲�;���0s4u.Rb
��u�$��~����=/��Prd��>��_��\M�"�V�:����)|��-�*�O�&����Z�g�7�Wi^�8Y�N{^;�Y]q�]l��?ޤd��89㔩�|]��o�o��gC��V�eXܜ5?�؞T4�7f<�f['�j��܂c���B�r��خ'�T�
O��5(�rߒ����abY�b�剿:�n:pUZ�s�X��M�ilGޱ}����|��I.�= ��L=��|��
~z�рa�Ǘڻ��~%�|�eQ�&:�#�G�T�r��M,�碥V��V$D
0t��ߋ�����
�����Ɍ��:��7$<��LK�ٓ�a��T#,&�����M�1�`2֞~wf��B���͛|��H�?�����Ы(�{8����de$���ˏ8�����
;����&۷N��R	Z�Uo�x����t�U����G��Q:tC�L�/�$nlh� �z��Ӂ��b��q��KW��g�n6\C��[�g[���._3��!W��]htݎ
_Y.���DA^�g�h����R�
'f���B���|I����_�����.Y_�1/dy��	��@#Gz��oa̒��E����3��?C8�t/f�Wؓ��bW���繗�� ����,%�..9B���;�i�-i�ƛ{X����B��i��9�XR�j�J��N��.,���rFz��}ۏ��|��}�a�S�l�gK��s�m����
÷n-r�������W�����z�4�RY�Yτ�v�=����V��E�`
�@Z�ן$l4�FH�i����H��� n��s_;��>o�T]yϝ	�[|VK'�S���嘲{L����c���W ������7�G�%��]���~�8��ƥ_33X�\���>T����{D_�U)�O?���a4�S@V5�3[J1��`GB�Ĭ ݚPLe���Sd
�G_�ǆ���\�J���iI!�7��Q�`�H���fk��[���_f��`�q0��
�� J�m>^��Z�Sx�E��4�W0Ǖ�3΄����ř��ًؙ��{}Ǌf�8xy��<<o<�K�n��Mՙ�����(Z@�wTvz.�h��We�)���l�o��{?��yާ�a��v;$^
����X�ѹO�+pFq �z0�U}�'�;�(�Yh4��H�3�K�������x�8�#yR��Q�6d㊔��v��'�>��i���Q��ZK�ye��J�X��HU8�k���S4]Y��J�9u���k�4�/F�v ý��&n�����k�%v�'�F�'����Kl6�<��o�S�I^�ɐr��W`
>�
Iq}mϞ�U���@�[�7��\�O�I�
���|��M�b�[�=ǉQ��5Ϻ[���n����#Ȕ`�O�y�MV�B�=�;�7�+ ߸QtPXg�h�y��}Es`���_��[�|�Q��ğl�K�;l��5����;"�8[�[:�!�K)��7�X�|��}�0��&��h�
1G<#K�=��Pa,^��=�4�&*1vc�a ����3��Q�)�(w9#N��-
d��b}E�@�Z���G$����@`a�5f�v�=X�V���s^��T�Q���<o�/U�$���Hݡ��^��sc�>p���y���� �� G-����<y'��Lu�.��`��t
���[%�k���>�M~�_��0�޸�¡�	R���bIL�fzP9�M�*=o����� 5��\'�Հu��uXj
��_�R�G��W�Gs��9�5���5k��g?z����YKe"����W<Ԯ�`����k�̲$d:gzs�VΥ'�Ma(�{�%b�cX�QL!ZU�u8߄�$��w��C�N�5.�B9"��sו�B�,���Ŋz��\T��	:�|�٬9dR�i[`R��ֲ��[7_��n�2k_�x�?��p殞<�:t_16���<�/k~6����~�C�������[vm���� .��ɲ���Ih��'��z������3!v���͈g�������R��Z�#c�P�+"�J0��6�*o��$.4<=�R�p|J��H0V� 
�`ʝ/L��P�h�Z�aB!����t��v#1>�>��-�u%�*����*��!Z�7F��C���L��0��i��O�X9��t*�vJs�
��ipNS�N�B�n� �:�\g��ҫ�H�ß���NMtn� L�:�_� ��zЋ>{�e����܁�����.GO�5�%2������#7*sCwav�88��V��G����C�� �e�uC۟V�����*)�񫷎�<����� �]�Pat<C�L0�4?��:s�׺�#��=�*'V� "'W�x;�1���*�������L�K�e*����J��p�o9��U#�Q4�v=��p��y2����Hpv�Y��z_'����@��p�hR%��iG\�[��N:����I����/��匝�G!�p'�L����8�(���GKn8���u��jγ�}�bd?�m�o����Óx)�`x8<�> 2�><>	F:�9HU�p�c�)��v�I�0��x㦧A�eY=s0v���T�-�G
)TE�\�|6��[��E�zd����/�Tt�0&���v#
��u������>��$Ẉ;��nY%�uƎ+�?����NT
����=9'$��)��yzX3�A�t����@ڋ#��.ٛP�;���D�h��af�Yi��°ÞzA�\���?��T\�΍����g"��ݞ�Sg�`;�_�"nOӋd�:�wd��A/̕���+��:g���4���ݳ����]��ͪ�wGg�1><Z�66�.>9(@��R�\(��k��pxx<^OWe
�!QK>\�
S
��W��)R��.�'���*�m�j\�I�s��h��9��O���I�c"
*�A���>�W"uuM���mV���j�:	��f/���'M�bb��3�T|�0�:E\�b��{)4Kk@�O$��8{��Y�$7>+���=�3��zp�R�d/�m��~]�67�Z�Lv�<fx�%Qy�'+4S�}�+j��j�nt�/�@Ck��ammm&:������(y�7�z+66��9�7�zs�GW��U}���Dl�D�y����ٗjO�t��B�8Gn6��`�m�gD��LW��b Cy�_G�-��dN�JW�^_�"� ��u,��m-8u0e�<O$4_H���ky�*1z�As��V4�ǔw;�}{~2b�u�,J�!�e��.A�n�rM��^`�{jQ������*�+}_�XAs�{7
�H�#≈Gp����U{�p<|�M�IT�޺ڙ�2塼ߕ&�bd$'֋�3]Ҏ�F�`�2;#j��գS�uN�o�gV�&z��`Mf��<Aо�<Qe���mp��BUm���ٜ-���=��8�)%��F���"�\�SƇ���m���i8����h�z��S�� �-EG��:�P�u��l'��l!�u�ވhf�L�rR��c�D���CV#�+�SEj6�fΡ��6��~�e��HE�aV<�O�\���eH���6�i2����гAQ���U�����+n|B���>zq{��|��"�����V7e�
��.�F��\��a���eiɿ�aE_��U�{W�K/��� �������;��Ew $�KBQ�u(�\�(79�E��+���[a�h�}1�])beQn�'��ڲ=y��ؽ\[�\@�B����b�#��,u��[��S㕍U��:4P��F�����z�ڊ7���R��}��}�C���3ߍQ��+�w�(7�$P,T0�~#��tW:�+�u��q���W��>,E��S?��ح�Rǡt+�_1�ޡb+�)�Ӏ���NI�����ƻ�e��8n���&a��ȫ7��ʤےz���L�*���hV��:�f��q��7��&�v<����+%f�?��R�C�fD��d�e��$H�:'�9��Z�\"����N�}E%��\�����M�G���8Y�ƌ���P��(P��x���ȸ��� ��`�W3<8�ŝ�A�/���`�2jX����2M�ބx�5�mb���*�D�Jt���O����t�L�Q�Q��y�����}�/��M��O�f��ؼ.�l�弬�ϋ/�d��vUǪ��BC���U���[�0b�F�\T�����e��}x���w4��Y�cMH�	ޓ�c�g�����JhW��I��;y������O�����x:�kj�l2���F�}��|�,lg�4��W>�y��)�P�X����h�im����r_��b��������I&�٤kCG���Z�ꬮ���������(]n�Ey���zcjoX�p^P�$y�=��!�oϙ��ن�hA���:�c�/��SCb�A�u�����
+~s;$�� ײ ��!*��#���)�B<V
c���J�ת�����q� �sfr��6
���8�w$7e�<ב��_�_O�F�ؿzSD���s\^3cGۣ�ٗ��t�{�K���WM�t՟��Z���O�r��}�>����e]����s��T���?p�$����B�(��1	�#g�qM�xH�-�#�⌜k��4��.a�V�շ��u�rdǴ�eⱒ([��5g��W$�ç��8\�ߨ�i���*)�M{˙o�L���?�Fs�޿z�?	2/�<s�7ݩ6�����P��f9+�mLpv|zM�
���,b��QHS����5��U��q���(y.���no]9��sD��ak_�� ���@ٯ�t��GL���Աs�h��ڨBWi����,����h��b��s�(z��P@��^$c-��~���P`d{+1�q��T�͋����7�SN i-���7�4�4���b"��,��cI�UIC��ӏ�Q�Ѥ�R�"�hn�8��^z�&��Į@	;�P7r-I�쯋����~7~2�y3�S�q��r�L��"��#`#Pڐ��5�<yċԖ�����j��RCC7��#��J'��t��K_�O����Dz�gz�$i�Q��^,T~#v}.��!K!3b�D�
zMmz3��:Ɇ
\�:����/��i���Y��b����q=�p��f�8��PT����d���e{�#,��N���V��z[)��	�K]��Z�XqU�˯�v4�X%�n�^�ٙ����fR�|��q���pJ]��R�m���i=tJ;�ʎ�ް�O����l�o1%�-FU���:�L�����:�fYK�(^&��i�GOJ�Ū�t��7�l
y� J(�����(c[����n0l���BƇ��3�f�����^��x�.�/o��#����v����x����KS��Y�*�"�me-����xY��ɽ�u�3���Cb�m�z wZk&���ܶ��
^��Aߦ���q�EEQ_T۳�f���ߍ��֎6�e���@�+FX�����F2�Fm`����K	*P������$3m��e��N�`g�\`@e�� )̶0�7)�ol������	��u�Iz�6KkJF��7�^��G&�'��|u6�d�f�-���p����˟��7��vgn�X�IK*d��VN����,�wc��ۿ�5���͉�2Έy�-ΫҤ�X�x�M5W`����̴�|�EaX/��|��[^�b���9gJޛ�2 �#*u}F�A��-�h��l���Y�ӝX���H�{T2|����Lq�&���WMQ{�<�2��Q	R��d�a��E��]e�0�q�FY���q�}�����K��=�)�ٛ0Q{Ý+;���G����0�KY��Ixt�u����*ut�I&Y�'��4�/��I�|�*��8\W�.v�� w��a��N��dX�Cp�g��B��1����h�5T5��7�*u�_��u޿��ի�� l~�enO踍��%le�>l������bRZ������&z����D���I�BɅ F,�� �6�n�v{ k!�'�x�Ѭ��va��Nk���)�6R\�O��~��"���j"%�{��` ;�I�ȼ�v��!N{��b$$��XU��
�#%0��
�t^PA���@�|*�\��(���j�	���6Ɉ�DԽN�qi*.~@�<H�!�|Y� ۂ��*��e�FRqVo�bS���N/�>�̨
	-�ժփ.��Ə-,D���U�NcUM&�ɸ۱3�a�ƶ�R؅�[��B�I�s>�qy��ǫr��sg�[k���A��~��pU�x�2��7�C����1f��\��.EPc4������d6+�
�h���Y����3�'LԹw����H6G���+��Z�fЙ�W,�U��8�%$K��*�7�6��5p�S=��K�k�����u���8|��jN�͌���M�\�O����Ꜿ}�[̩Y��5 z������������kϋ>�0����y�Nd �r��o�@K!����H1�s��p=��Z�9� S�YG�4չt��~����3��>��h��e_�y��,�K�Gl	��=*�l��������ǚ�}�3���q�� k!�x �� u��5���>*ͺ�h��t� ^�xe�����7����b��˞� !�^�m�V1�k�0�s<5$P
юV����6~�� �9{��$h3��������_�x���ǿ聍��W��"��a�o������_}���
��ǉ��U���s,��8��^(����TI�,~Iej@WPH%���;�����N���������13�w��%�_!����ùeeG�@�������`��b8[I@��{~z��,�{VG��B@dC$�9p.
'����Ϟ�:!301]�=�j���y�����7� V�Ϥۋ�C�3�G�6���u4��Px?[�Z�8o��6�5�8ҸZϯ��}�ѝg�P[�ꖑ���MR^��J��[��9� �<���D����D'�V0�;�3�}Ҷ��2EZ���|��@� ���D�h`͚\��x 2��T�	DM��}s�$���6�{]go���龳_�Hm��m�쀮\�,=$mP�TC觰���4Ǿ���0E�V��o���|��x�W�h%-Զ�T���}{?���땰!X��G'r��"��M�C�ϟ�Z��$��w���t�̄×J�
� �y��#2���T��(dҞ�{+�\�ʧv�\�aG��zF?:�9{[i����	j�d.����tG~��I�OXCo~��q�%q=:���%g.0S!��6�|>�彾$IAk&����F���G�"�3�xJR3ZR�Ӥ�,'��Q=�����v���-���������=A�����.�捂�_Y�	=¢�d��/�=o��=�;��K��T�VIQ��&l\�d��!=<=�N�L��a��A��y�)�3�ᅐc�l
v֌�8ߒ���@�$�ĕ�Ȉ�����NV����>��
j{n����;���}{(i/YZ?�X1�8�g�"9�K�'�7� ӗ�z�D+3�5_R���¯9��M>`�c��L���1��ׇ
Û�]����������BH�N�$ b5zЍ�;K�x	�F�UBEU:c��I�~�J������Z��v�E���;1*�+/�P��9X�,�״��jM�ucPSa�6�ۿt ���*���+�P���Z�l��n�^�)����+t�2�2��7v�lϰ�20dP�VǮpd�!Mre!����K�y���3��t�dI,(�]����$Ң��aV.�7|���r�{.ubkDTru;�nc�^���hS� p�m:mm~{���pV!x�����B_ ͗��k� r�W������k������1�RlO��f�G������}��a��N1j�l���{��`2�%�ğ�%�g]
q��X���96���jƘ 
JoC�[���@m1XJ��J�.�_��TD{\Ca?�
����&���r���X�DQוB��_!!�l⶛���KS�7�a�+?ˑ���er�w��^C�Ϸ�� >�}k�=���������WO&�r��84�:�uf^_4���U�^k�	$|��e�]�d����d����q�9�+��̇p�b�=���#�|�
8�_� e�f3�l�>Q�����Ѓjt7rR�Nˑ����".I=&GM3>+C=>5{H9>F�P��<�����ԅ�%�n"��(h� o"�OnT��ׁj&����7��8
 udM������f��e]{A�'m���k��'�ի45(G0cHƣn�C�0���$(�0�_![V4ߍc�OH��>*7#y��"�����������ٽ�ܳ��u�ɛ{��9�J��~�1C��k��/��H <,��{J�
��S�"*� 0	5֠"�0y)��T,/�R�/!A �av&���o=+�g4���$�W��E6�L!!��b3�� ^Y���|R�~�!9�Q4����f�-��WD�l�bā������}�t��~��F�W4t���0�{g��̶��$%!�#sPlU*} �������I�Z��rж��q����mSLʂ� )�����:�T����:�yi�s�^��q~})�Ami���4PO���KMq��0&y2�����teX�\���Ӱ;�_���,� ���{"t��WM�
��>�s�u�uE��K�A�6J��D��I��.��:�r�g�g.tG�G�'��������B�=��ey7ꔗ�N>��&tw���&�Q�'v��R��;$���/ݫ��8�30��-k��<p Z��F�E�ǂw����kG��/f�O���R�	i<����2�'OI�"&P�N��҆�oOE
&/J�/mC
�	H��n$\�8n,&
@Ɗ
E�����O
n��kU%������[M�2��M��RM�3@|����J����L�c��%էAT!է��K�8�E��C��#2�����P�����t�q�T��cMc%���k`Zt��t�ؙ D]
��;;��2M��8'�T-�s9NyA�9	�'���rUߔU�eT�/{_��:���j��֍8�v+��(�i��Sx�k���?�ȸ�	��kP���5!�G���
��IKw��M�&G����}��$j��@�c�ůɌ
�%�d�R���g��Jt���N��#u ��x����R
�����_���(��@:|=	�C-l�s� ̂�C���]�[��XJ����%D�o�Fz��d��-�����2�u��Rn1=D-9wû"2�)[���]w}�� {L%��Q�x�_.!m�����}I�������_�ܧڭ�ˣ�@q���T�/Ä�@�k~�]��'?�WP���L�PG��A���+�	���įa"�H�X(Ọ��h4����Hh���+\�O�V�M�Z�D@5G��eG>�
���CI�M���j���:>Ĩ�&U:!�-&���S�{���̯'�m`�m?�9���W
�'�_.�zNE����i�C���)�ݣp��GM.�9�.�S`n�� ��e=�*),2p`.
a�?�OJhH�/<�&�����E�l��3�x�&Cx�z���,���7a�7r�G�>�?s���p_�o��Az�o����j	�l��Pi!}z�����7�Ő0��=]�>!&�3�y�����^�|�4����&�;�n��D��}�T�kuƾ��3ua�0}�Q[W۴�B,:�F�^I�Ç#LKMw.j��Y��1t+.�5�60�̳c��I�D��O�W;�%���<��	8�������r��#���s��X�#ZL�Cv���+G˒*�I���&�����y�����/����k}��D�+�J9kM+�a�%��y��d\+l낷J��Vk&mJ@�E�r����v_�L7�ftf����_kfq���w��R�u+����~��*����!��J��x�O���gRJ��o����1�g�m� nh���LǷ����8U`�%�N���̖�I�����{�#Y��E,���e�!/�ijz�1�q�Z�5��u|��*)�9+�IJg�ڦ����a�����/����qY�XÂG��6��$�U*ˍ��߫WU�	6���%P�u�H2��C��ڨ�fF��PH/����մ�KY���XZ�^>֬r�ߍ���b�e�Uw�%:�6����o"�ɔd6�4�U����s�ȫ�;�����O�U<�7��~��u�WØ����+[�܂vW�e1붺M��"�{�I�퍝W�s��VC����z�G_k[�y�4��
��񟝫�	��F�S���<�G�c<߅W2��i#�m�h���k씑^s7����$e��2Z��<�L�/���+c���[�Oc�
�П퍚�Gi�ۗ���+�EU������V��lW2�[��o��@�����~�����/�d�/��6�:�MӼ+n����֟��ۂ�.��+�[k�'�$��$���Q�b�,�_��hʏ�W���מ��{�E򧦛 ���Y\�����������˒���e;�G�7�Z��\S����*蜤�39<�q&�[2��26�U>��O!��������=��V]2�O�QS�L
�#�U��g����k���g�Yu}���"�&9��X����,��\rڔ���ٷ<�WsMޑϢ>2?�ޚ���1�]oݧ�h�s�2����!�_����f�$����c�I�:oj��V��Q��*`%@�6�a�UC���Z�����k��O$��3��L�	�U:���2�|�fib��X[m�LZ�r��<�sE�oe���nZv�t�P���48앋.�Ru=B�2N^�_(��`:޼�Fj��>	:�}[f�YF�����%/� �|U%���m��Ǚ��ɖ�������L(�����e��H�]t��v*raJ��#S7h�0Y�E��N?��&8m�tw
��7rX�o�:<P���N��Ǫ���۵�[�_{.����K���;�jS���}=�ͼ�w�"́R�k��s_�T��2�.Y���!�B��%�?��4p����Ӂ�^�G|�c�[�o�h%˰L>Բ8�iO0��2NP3�FzEQ��x�<C�p�a���V��"��z������TZ%$����l[rC�+��Y������>Q��dg�i�O���Ӂ� J`p<�)l���ݓW����T]߁	����6���Ùu��\�iB��rw6f�͞�e���uhxH��b�fv%^��3��r00X��k�:˲[�f_B�xv��j�2��j��f��i���sԇ{o���V�E���Vd�����u���nk�v�'���i�o�7W���T��h�ū�J���	A�ּ�I�S���<��ĈP�+�����C7l����e0��
����H+Z6�O.}c�^��K�(ܙh科L-���@��6�
[�\��G'|��+��J�õ�����E�+�Y�C���xI�CS��]����"�emHЪE?c��-ou���k�Ugur�LA��@9�����ۯG�����Q�v�$�:�5��j�$[.�x�c��V�j��r��'ʄ�`H*	��!�������BQ�-cq���Y[ۗ����k������D��0��|�mn��_h��JG�kc'�ȿ��ͷ�(JQҚ�\;Î[;R鋤�u+��tl�V�5:Ԑ[�GX�?���oBk�О�ֺ�;���PhR뭾ko���e"�=i�`��k��XV]wjy��V��9�-N�j��Q�Y�'��l�|{�J�~lvv[�!Jnw�޽VQ~��\�� �D5=�aW�7�T�uF��/@c_ g�U�Z�{�Z�8e��/��A�v{�{d�Ibi8�!�}&���8��4{诐��_�>x�nr:m���z�h��L�3B��?��$���$���Y"Mh]�.������#�-�O��C����YH�^����b쮺��쏣N��o�?&<&Tx�}�&"J@]a@��gZ�W/v^�.uO���S8�/>�sOf�:�	u;��z,5]?����)�4"T�a��T��3�@N޵����G�
���n�s��l������&W7x<y���m����
�	�b�.:�J=�?�K�h��5ۦ�._|6{�Lx��_�*��[H����.���rc�H�#�2{�I�={�E�3�W���M8X ���D��}Ӛ�72:fYU�$o#��b�@�P>f�r�L�w��[��Zo�6�G~,GE��v�m%�r&֨�����(q6��_OфYe��|^�r}7�7�:�9�qp�?U��O���Px$��B��V��5����Ͷ���ԇ=�O�Z�,�khi�I�a�D��=TTP������4I6���e��!`aNF�3�C���� ��;�� pG�����@���ޭe�;���r�:0�2
��MD�S  
�;1P�"�9�c�b�b}��GƉS#MBQ�U��c���1�K��\�aB���
��E�;�=�&zOܥc%\Oܽv��MII����E��)���U�/�9��<z��o�����M}��A����}L��;�do�"rfo�M�� �<��os"�I@��
�Nʩ�E.���&5�I�F������B���t*�''^Z�Z蔠�825%�7HC=DR�
��'��c�]
vҢa6�# ��i�cJ!rո�6��a.��@p�
�&�7����CNt�&�[c�S{����BQ%���4�C�v���gAN������o�L�(r@Ʊ�V`�'�y��A�����x���J�� ����
0��}���T0ʀㅁg�a�TA�M��9K>A���Ġ5$g=��x����3��� ��!6��r
���b��d��u�?�?�i^�;_);��zA 3{�3.�O��)�WVc�'��(t��s̢�
��
�5�n& )�M��,A��M��<��N:���*�����+��@8�|$�t�ۇI-#��3'���5k�0=�Ӫ�e�?e/#�
{����˹�@�}g�8�5HSG�ɏ=�s37��*1�i���6�JD�ܩ�i�QU눷�OI X�"���Xq��c����%��
T4����/�UAf^�J��z{���� �oL�k�2�KJ�͋{G��R>��婵� �)��t��%��O�-t@!( �}x��l"���q�<f�%Xq�}�6�LA04zVќ��{�*���u;���e{�$��"^أ̓�@b�;�� �X��jv�pZ���6]T�&{�D��
]�8�&�ѣ0Ѱ!��5)��!��ܼ_*�p�����#�1�0A:�E�Z7h?�bb���� �vlC.3�}(i�)�m?_���	�M��%#�]�o��ٻ*;�D&FI�߁�R�{��%j�]�I�#J:Ұ���k�!xw4/� � ���'����H���f�G�,,w��6�A������ >���9�P�s-��!��'�Ü1w�Ҭ�-~u�A%ܦnA$�%�5����{�H�p�(����鄠�/�粼%k�Շ9{�r���������@o����/(��7���ᕩ�ܑ׭R-�X�>/�gԷ��y�uF�����q�Α�ԉ������!>j��PN�&}�\
�,�2>��jP�
P��w����������-^��nIk�Zze_��iG�RLJ��%�2�RRS��1��mhP�� �7�Qu���v�QG���g�1FfӀ̘�A�T1#8�3D:&-��	�|8~�<��~ )+�
�(����Ap5rGd��K������ֻڅ��6�����L��l�|�A�*<���t(���A�bB'%E���Ѻ��o^s_�J��L��*s/�ȫ�W�D琵e��`}�l<5n��S��E���e:?VMφȬ+���QK�jlOR��R���A`r�|�yy�|L���������P3l��$(E�b�rT�.�Qq_vL�v:�.se�/>�ofC��=�>�z�xl|a�t,��
����y����NIg��iA��0ل�XW��h7�s���NMâ�׈Ɲ�Jֈ��h��>�V07m��Sؕ±a��� ��(p��0»�ݰEV�5x2҇CS�J�+�M�܋X�&%���a�z�0O�f
N�.a����g�����o�+]+�YH��;����a�=��J��q]�{EE��+-t��Hi�

!\B$���ڻ�,4�!(`,( 
���TE@DD��{o��}�}�~���ٸ�3gΜ9m�93	�6\J�R�_����~��R�ۅeYr�
5������R����G<���*�f�'J��_���`î��
kʕ��=
�av����^N��Mg{T��^��Qu3��IM��!�)�&;}��>q���֗G|�_R
Οs�
]������1�/A�GiU��� �c]��d��G3�K�-�_��2i�E�qS�.�Σ/�^8y]�g�������*�guiavt����M�o�Z�+����߈�� }�؃����&t}������9���WΓ�[-Nt�C�w��*p��~_B�����P�R;�e�ֺ�y�����$��?���K&TmH�
�ZcD��W^⛗:/+N�ڻ5/qsa�׺��	�
o�}�x:&�"1������GoǨn(n�_��gQ�=x��Qk%U���}Ǐ�ĶO�.�ѕ���M]��Mj��	v�u
�k�&= ��xLo�ʁ(f�������^}W&��[w����u�����H��k��J�y�M�s��H�z�3�8p8�m�y���_�\��Q{���C&ge9�UGm}|�zZ�ԁ}��ݧ����7�J/��|<�)֛xr������/ܫ3��f����<�yɏہ%�YV:7���:�%�W�C�v���*����ʏ}�ms���;ƻ�~�2��!�q�Wi�E�N8޲�k�Ǉ:w��q/|{�+Z�cϩ[�:q��Gf]M{��o��b�c�{3o?��y���VB�ͳ�g(BFr��P�^qX��X����-�|��Y6s�[�ѷ3��N�������[����y��/>�{w���:�3��W{yG���-%�^
^�����ž���ڴlfs�*��Ԭ�s���i�	[�dT4�r�*�`u|�e=��zEi��a��/�n1!�E��*�M��]�HE
g��;���sK[���;ׅ?�;���ϫ0K���ԭiښ@�笋S|�I*�uj�oz��O�[7=�?ج�@��d���TV��Vo�ٙ}��nE�//H���\Q>�wՙ.���C���W���u�w9>�}�g wO8��C�)5��E��;�W�p66t�����[�]�����m��d���<rGO�����q�mp�y
l��֖�Y��`�ˏq�B������Oo�+�����ٮ�̃���¾~ozRӲg����T�S�t��y� ~��V\�wu:�FY*ivD�(�F�3��O���5j�L���5����"N�is���7�=X�~]�"��Q �2�|Ut�����.��*�Kj#O���#JnO����Q�lWͫɈ<=:׭�<K[��*xrb�1Kf����ڗ���լ�ҟ��"�����1O\.t�wJ��7=U��{ˑ}q������w3sUԮ�����ꮋ/}2�l��	��mh���P����y]8���X'\���n�_L	9��hnZ�^"���q�%�:�}��������d��[v�Y���cć+��M�gO^�,�Ň۾��'�&潜4w�Q��۟RV1��}D��Cci���|�PU���:��k��E�+*�|8t ���)��S��/�|w�a���O"�X���b�Ӯ���1�)�l�p��%4��|������aZ�o;���C]k�z��Ɨ�5o.o��p��u��w^:r?���������?�c�}(o�}Ύ�zM�1!-���I�_�+	�Z�������F��&֍�����\~���mk|+QN��EZ��.��|w<��Y2K����y���%U>�.!�r�V6)!����������e{_�� df�T�~�JG�Sܹ3)3��K*�G=���ɺ���������/�l���L˚~����~�f�n8�Wph�o,z�͓�9�W�$�&�
�ˢ�g��{�L�����ћ����������iW�.��[)���%������(%Mw9jN�)�+�G���kzAt��~��>�.ǥO=��SY@��h>Y���J����*�w��
�Q�V���r�tF�'�n�s�W�u
��[�.�(Ӳh^�����e���Hrk�<c�z��6P�*V��*y}��v�ޮ�K��76�v�
�]�~���������lZ�?�3���!��Z�č�C�k��X�.���!Dݍ#�>���A�q�w<�?��m���Ocζ�����0~�̾é!�ޭ��Z��N���+���'�+�Ͻ0ϫoY��k���z��7��SZ�F��`�V�H]�u��x�q쓦�v/��0i�,�^$����-'��37y�jtVZ�n�֥1{�b������3{�����WU��$l�&��I޼e�����]�=	�O�WmH�\8)Ѥ'��={�j��\&�K{t�����f����������&���=j�wj�GMM:�7*c6Ԓt�Q�~�t��Z	��mU���wm�^O�J����ّ�\��<*0k{��^��k)g**�Z�	�~e��~�zR�>��R�0���������_M��_��B�ΐ����yֹS^<�0jO��!/f@�*���I��<���άX3�?4�Q��֍G�/�˱�h�z~�Ջ�>	����uտ}����矻�_߷r��;��>�P����w�w����-��;���W���{eclc�jQ��3>��?��j�#$��������!��aV�I���y�X�ok���v�*�����}�R��e�ԗ�"z���(�xj~T�Ԕ�=��{䧮{'�^���G�1.q��Gd�X����\�9˾��ݓ�n_s)��ܮ����:;yN��~;|v�醛��R3e�����}�Gٳ3���P��E�;�8����b������-�{X���[\�N�>W7�L�hm]"QS5["Qr����:���B�\�7�r47���$fP_E5T.�듛������뢐�~�l3��Uמ�����P�m�>��1;�)����������D�	s�Γ%�/?�~��m�G��[���wlo�|(w���c����
#3�Y�Z�d�&V���BÓ;��4�LWk%d���*=����fVԢ�Y�R�2�M�ү�t
�k���bu�wNh����4��-����42çt]j�����經n~���=��><����x��w�9��Ĩ�AE���V{e�m�l��x��֏Ϩa�m"�\)�[��8~A�����7��t>�1��޲KO�Gk��~{y�'o�«�d>9̈>�[yW/IszD��:�_���X��ѹ�O]�5��u���Y���.c���Fpk��8�ڕ�����k�.���/�,h������/{���~�q�ǖ>q�/w4f�UX���������3���V��d,x̲*����;�Q��.���� ��]��u��z7b����R�p?���4���6{��v3�v���϶N`�7���{젔l\��	���{L}�:��N��������{��������O�����i��y�7%r�J�kN���'M�2�_�#ei{`��l�?0�i�e)k&͘3f�K�zʵ�їe���V�kW�K��T�8e�l�1�M�w�@��)�URS
3{�:g�n4(-��Du��d���r| ����������3_�g)����2j�$��Lɀh���]�ڤ�F'=���Q{'.�泭�WF����t�����Iu��-RZ�����ʭȻS߻7֊uh7���NmDPumN���}3���>ڗ`����9��?�w�\gw[��͟x�_/��:E[�`��I:4y��	�.?�}H������T�%���|
*6��,�TT�U����8����QQQ��c�Z�`\f����`�xI�����.�,�MqX�w��Y�j�F�H����a����-Y���`�;sF�
*��M�5 z�Ӕ��&�{V��+C��zh����^�,�W:��ee��[ʁ=��>�}����vu�Ϫ�F����
��I(
f�*�'�I�� ��b�q�*DPS����3,O�%+��Qd��L6D�;$ӓ����A�0��c���۩7�IA0�	�K��A�<�H@���"�7���	d�����P&��Q� �e�!�OP,�?A��*D�	Q��L�Bj���\�FB� V_
D�P���Ak6J�D^���6���,��&��;�΢��-�. O$c$n�Ȟ���>1���G �O4�A��e4����!�a��e�j�81���E9'�!���X�6b��_��4X�1, �A���� �a:�:�1�	�`�|��-�t�!^}V����r�ü� ��Z3�M<��:�� ���'���V!\
)��YUTT�i:41�
Ԇ) �L���FQ8�
�("�l9hB�&,�(����
�}`�/� �.L�J� ��d�ށ�*L��:��t��H�6�0�������!��0]�a&)�r6B.����ˋ�4��0��Tn�:�Fm��*�7ȿ��N>"H]&P
&� ��F�GQ��AVc2kO�,0��5dt(��
�`���H�*��Rߦ"f���OyŰ	�~�M  �n$�F^7�F��!����0[�˟:Ad�#�Y������G�	!�x�:
 ���� ��#@S��2�@׀F!ڈ4�yl6���80S�ax ��o� Qx� xZ �0a�?�0�d�h��2 �'��`�FG��#"�,��&�"�a��p9*�<9L�#n�
���ph�,���a�!��Z�����6��	8L��G������_p�T��%�t�X]ю3�U G�B����#do�`�h;X��1�]�G�/ 8*`���OQ���(=�O�'�3d ��'����%�1H����I�o��H�B �$�|ѡ�\�
��&��m�!n��"��4����,,r���#��ݺh�T�F{	��K@�����ݑJ�
�VP��(C�)��� �c�ͪ5f6����˅�!�D�(:��(*�(�#p�rE��G��g"�O�<��Rf�	�	/(V��!e2R�`#U;�, ��rу�W�9#/�-2��`�'�}�5�� ����$X�	��9#�_	��MFX�جM܍���&�x/�s�1C(g���C��� �P�F�0��CC��f�
�6{`K�����������6Z��⮑1u$�ht�������XD�P���#�ay�h��p$�y1���=�N�}#�*�T.�>4y���@�7�
��ș*3`�_���.�c��lZ� � n&+X2N������SP[���<
�<P�aZ$"�t��L����H#X�	@4�	�Q��3�Oq�h�F؉�~E~�!�|7���I�����KE���2XQ�-�-9��\��s��у�1���L�T����G�����*a�[��34�!����Ch���
$� �TXc� Q�n
���!�}�����h�?/] SQ5��1 �S�Q���?<G	�,�V��(Em�x�O���8�1��e�1v�#1�N���A8�f��ŧ���/��x(� �Ѫ8GB9�Oq	勄�����"4lU�.�i��߯����@bw+�HBΥ���l��E�
�^t��"C�T� �XPvȣ�(
����c$� ��mP?�=3 ��V"�&��T2z5_�O�\�����N# �{z����"u@��A�:�j��Dd�z�$pb;c��Juǌ!pIzhG\0�nJ����d_(��Ƈ�xҁ����u�4�!�5rs�?j�J�b�V?9��y	�G�~��ڂ��^"�]5qū >�xZ`�[��݂{��x<nЦ)f����G�(aG@��鉁�g�Bc7j����P?��Đ�ɘ�#��`����0;ǀ�,&����2;~(����h��YRG5��a��l�D���+t���NCD��D�$$�wDqQG.v�N)(t#f�Cr�!\�2�T��xtr�)0-k�f�DW�E�
����a���]�au��Qԉ��/�&�fƶk�E8�zk>.$����Pv�V8d���=���vv���V�1���wl��H�Lm]�uŋ2q�EWs��A8+�R5���	;@���މ�di���މ:V��G9�Ke��CD��q��
֎68[� _�=�0���*���t�ϊ�j?��H�T2�@�%���Ԇ݃�A���B�'����P=�S�o����N�3��@�X����1��gV��\xdf�, �h���Ċ�ض����G�ݷ�N`[��^;���0t.�YDv=$9�n��E  �I/ډݯ����0�0�J�\B ��WsG�#0���/�����7D�\A`���(G 
�7
	�F�ι���Eu���@£Z!l��MĚA��"��!����SRF��	�`��*ze�GU���	vW2���#�x�2��� m��nYo�1|��X�K>?����4�Ş�h�����H1��dx��_� �8Ջh� =��q ��
Ձ}���'���鶰�L��4���+�b����[�}�9�����]q*
�^0v��(������0��a
��ɅŢe�`�?R��fL۰�����~=Q0��F��L�B��~�#U�ԛ���>L���7:�Z0b߰�=�)t:�%A�,��?�j���'� �~>MF�C�i�V�t�� �>V� p��r��aw\� ׹�aȇ�|�Px'�'�7��%6��JG{k���K�����df\�2� O�ES9�܌@"���C�J|,K�����`N�OxbS��gî�`g��k�l�x�8��`�ae�*!v�����(y(˚�]�\]�mt�6�\]�m��r�m۶m�]�q�W3��|��{��j�9g�ؙ��DF<��2�����L�Y�����?�Z�V�������?��󖭕��;��$J�N�����{o�+��G>!������G����;C�
�N�������=�7�����B��%ֳs5�#��T}UR�ו����S=3��9������������jc�-�$�G.��lѿh��D�Ј����y[C��� ~BMuzm��f�ٓP�{�$�͎���K�
�_��W��7����˴����{������V��
�E��k�[�����~������ؕ����������}�ߺ�!��OO�i
8�� �@�����0+������)����M�}0�~���+�A������{�?��o��Q����ӟ[?����k�G
�����2�������2��������d��l�A���/�W����˪��szĄ��j�7!�������o8@���R�m�Gk����4���]D~[V�2��i���^���U����������l�������y,f����{&8�����CCG�@��c"�c�st�e���B�#��syQ�[�����(H�u��o��@7;B*BF��L�����?=�ᆇ���V�L�U����7�������?/��v��ϰ�ߢ���_T�?���܈���
����a������e�Ǟ�����U��9������ �Tg���3IWHYVDZ���ν�.��gP�ow�r��������������M�ee~o�o��{��>1���v���}bҿ�������'&�����g4��_!꿱�8��#������������{���������������5u�� ����7㍹�[�������/��/ MHk��C�������?#��5ҮE�E*��{X�O�;��\n������!�I�G����j���P��D0}kB����+'�}�W����7@�o��g�?��W��`�V��'��M��	���\��u���t�^� �5��������I��"Y��Z<4b�p8Qj0sq���; ���<m���+���zw�@�k���
ZZ�;�g۷����M� j>�n���R��6��`��\e���|k���OhX��X;�ތ�5���ý
�5����8�M�@D!qMbYmf��V��S��`�Id�'c�ru�s ��I���ct-����� �߭����������s���h�a�.K�c��5����VC��f���F
�᏷�����������ۊ~���
-�������Ip;�r�s����~��=^���� K��3�{2o�D������5c�ʦ�>ޏ�WA��l��/��)�������ʴp����@	O�A�����
�t�4p�Z+��_K����
����i�j�>lsz����y66�w�bu#k#�甍�TGL�_���EЭ��h��$̲�nx�w �t3J�H��� ~��q���Tmp�:�[&�ڄj,to �F�A2f-������vv�J�+�ıj��C�0%���&�;���"HpȌ�����RN $�тnd�1��8s|F����V\�S�y�����4+�@��0�� �kfRm�c;������ʬ�����ĽŻ�����X-E���i��z�P��h�k�mei�עo���`�#ؒ켰�rM��(0{��#�O>-�������v�`�E�:��Μ�i��6\
�W#�ft��;���s\��C�K���ƕb�����e0�x>��yO��2���x/��Ɨ��i��/ۺ?�,�{S��Iy�e:�B∴��Y
�S�֠���9�w�P!�(�WpG���vV�a����o8>�3`Q$9Ih��z�׮����`����N}k�S�&��_��@���:� ����F���}�J��4�)�׭�{ϵ���Ñ)�
�M��+��v�M���:>kH�׭��S�%���6����^B���4p8
e�5� ��C�}x� P�s=J԰�	��{��k�jq�SJ�L"�)Ż׼
�{�^���B�>^n�=� p
���<r��7 �׷�6W:W���G�D\�ㆪdȈ��X�t�ۉ%�p�(�Gi��O�"Lk�|�}�hF���]�6��ik@��XU�OS��z��bWk�/�d��0�}�'VK&ϏB��^��v����e��R�#h����ۉ�̇�x��[ɬ�~9�ѻ����3�i�Ʃ͖?������	
�����?�ɏJ'�s���#
ӯ�y�y���DC��a����C�JC32�DH-M�n�l�$~�d�+j��
M��=��3�B1��C@8��,�0�Vj�� ��ej���r��;�����������q�%bqn��5uNܬ�����f�������?���0�n�{��6<{SV�o)�2�	�4T�߱˿P5���h��<��{���U@��ɲ��X���Htk`�x�5��@q��B��/��z#���g��4��tpp���c�<�������b8�'�8�MXS\o��eb�C*\28�!�<�h�-pAg��"j��HC`�	u���S(h���Y^Q�n��m�q�����78���w��p�wL����9�U]�P
LC0���z�fu�&�4;��Q.l����y��&O �QC�3Vkf4.������ʤ&
���+H��L�2�����P�t�}�03L�.Q�[�R�#�뀼m$|>��E�s"�"w�����<�T�ZW����~&��m�]-R�k ���B��/.�<Y�u�`B��n?�^��Fi<����&���fҝ`�vt���j�i�bH�^|�q���ɺ���
��	N�y}Jw�Vs'��l?Z�|���y/�t��	��N�Ϻ��-}-�/>�|�߻1&1j�S��.��
�5e��{���
�|�'����f1�H��ġ6�}?���"�W]+#P��S��C}F��c��Oh�T�U>1x������@	�Ov�T�w/6pmE�-����OǊg��P:��
��I��$1a�n���%˦�_]Y��4�z��ax!�h�un��r�������Յ��Rm�0m*�{���ȇ�sb�d���_S�}i�oǌ����"��c���
v�&H4�ǲ5jh�Y�1 �BP>r���(͌O|h6?يMݿ�*rG�gƟ�?I�k�FU�v�k���R����
e�{ͪ?�k�!�L�0���ԻnbBr���ܪz�~ͅ�8�YK�^��l��;��B��w2�gV������T&��4[ğ�Z�Dq���j�f(m hbϬ�Se�yA�Z�_t�ۖ�mS�����-+i��(Ă`?����iV�ܾoQ�:?�n���'d2-���(��<rt�Y���50b�3O0������Vh/\�*zk��0��{�D��'
3	h��L�������R���uҜ���l��c�'�����9�I
��`w��;$���Т�g�X�S@�s�[��<�ؾW�G���@�.�T�(f}T��Na8e�uρI�_@�i*"��{�ϭ2'Em�Qֻ�
�h� ��T ��0�?s79��Ѕ<ל!���dH"JG㇉�^���"g��.�D��QfV�A2ōSBM)�A[��H|FO雋cW:��r�eJ?�� �R�v���9f|�toT�jm�BE�ҷT-��~���T��`7��gxyGQ�O���!M�X41bb-��dnL݃��3	��
Z};�O`M�����@�}�9��{��`H���~��3�A������
�z%H�
M���O�r���ؖQ�ǨU��"Y����M_��s�a���	�3�ѳ}�����dtR�&��~�F����ϖ&�_W���RaX�����l�uT���  Y*#�v�Fw��k�
Ǿ�F��
x"��֞�V<zqRNB��	aӰ�T���Y�����t.�5��K ��i��j6����"�
�LS���@��$�E<�H��_4�:��^��~�l��Z9z�,[Np��<co~�Fo�n�$ڙ��g��;��$E��?s�))��;�������^R�R��,�(��@됣�����]Pɍ0��,*�x.H�|�u��� >1B�P��D��1�8�4�^����'h�bd5���b
�Ŏ�H�gn{EY� ,5�,V��T�/ߒZ��ɠі�O⦴�åT_� ڟf|�g�9�/�f��W�� V�s���F�9�>�t�|�Z*�k��ʞ=Ϙ��`i��

�}���H�_���R�!��u��$��-kd��ܲD

����Q�@n3�����+L��؆�Vl�i\7�HdW1C%K�E�@�i�`���*��lG�*ӌo�S&U�`hJ{.��K��m��P�j��H��E�08��N\������)�Z�����lC���j�6��K��s�\D���Z��*�#L�3��v9U,-�y-Jh��5��,
ⲉb�s�Q���lk��e�*̖;�&��aK�����u��|i����g�K�H��]���e�{��jl��6_��EU��G�h����q�o�b�����>G�?�3�u_l>����6��]��"���J�*
�N�C\Ϻ��w��s�x3RIGk�܌�#X�G'���&�+�A�����|Oz���,Ǿ��OqC
K����\E#^�����	6ٛkMM��K�>֮Mu�!r[���]���{��)o�޺�$-73#�wD�t�K�����h�u/�RO��Ï/��8GC��爈��팍��Tu�
�5+����_�K���.�������G����p�����U�[y��R����1_�;>��F��G#�L�<�*K�U��)�HȢ�>�7c#d�e�~�>�{+\�t~�s��)9]K��r?�>O��kN�\��¬�vX��8���ٱ��8�����l�Z���񦞷��k��|4I��k�q8/�&ș�:T���&��|�7��ś��c���ݞf{�}��_��j;���fA�c9��­<ם�Z�U�N�����i��K����*=m�����w�?\�*�g˄�˦z��5��:�N�P�XV�V��y6e.�Fo�m}�x��x��}�L���EM8>]�������K���o[%Z	 ����u�>;��xT�ە#�XS}AY~�0�C���qw�y�z"c��cn�C��	�vv��� J �~�����a����1��W�ќ�Yy�p�J��5�T���#�S�y*X�]K��0�c�b�#M	��(1q��2��}�O7���@��v�O�|��A�[��Uc3��[7���h�������մ7��h��G��6�Ca%�TS��w <}�HG���uq)Y;�TzC+��>9����w����>�j�O�:ŏ�)����6���1�UVދ���Η���{w�Zg��g^���"yuכ���ݥAk���ۓ���_�g�4?pڬ�O�+@K�Ec�:M�W'�۷l�VjL&��?�vZ��� �����Sߖ�w�JV���0@9�g���E�4�輅ʳܰ�������Qi�=�q���$�삾��g�%�m=�������0��E=��p�eWjM���|y��C��rB.��"����3/�Hf��Ew�|.R�(����~�|������H9~Z���h���q�e���5�DL��xsEx��˭�||��[1��F�|�T�E��0��F(b�	ܨ�#�7���9���
_����d$1[��bj�U!�4���9�9�e���]�}X�9�:�r�0+�g���-���W{T���H-�l~v�U����s�Rj-�8�����yz.IǸ{.�h�_�a�� u��^����z�Q��b�*8�<LaLy�V^6-)�1����m1��m�Q��ˑ���6�6�	���W�+��y\�$U"vQ�JW�I������`�2;����,��O�e:B�s}�q�03v��yڧ���Y�$��m'#uU��Gw�^�K����	��Y�GeЯ���d�m�����_��1���.k��`
�(_��;U�����Fe��M�g����SM���j
�����B�r������qmEK/��>6�A��a��B�?��Iz$�5jK��䄯_�e��?����r/�,�fV�r����=>�����G}=7���U#�A���y��d��d����/��w=���m=h~9e�Lڶ��t�S��R���S{���l���F8��Yt<��ى�|��z
���M'�:$g�Y�����!H�%0�Wr&�Ѷ]�5�|KP�X3����h�U<.��k����H�~n�O�#�*��]z"�g���寭�P�ʻ��9�m�R��g(c��n'�(�-x�����	0�R�`� e=1�w��R�gPz�C:�"�^:��"��
zk����Xzat�{�1��s./Iqh�WQ,H�Dx�D��&�kF��M���2�X�G��ԝ� _}+�V )�ڞ29_̛�3�̟*yT6�ή<R�7�=^"�7+����>�$6��i�x��TZ��m��2�B���|
���*k���9s���7B�K�B�HS�u`v��]Hr!)�����\�&Q�ʗŃ���j��e��˱I[B�����O�h�2�H�?�O�_��w���))������gF
�
	��-����L�(0�S�.�E���T}��"K���b�ạ� yŁ:�� �O�=�T���2}��V�����t�rE�	�ɊŒ�c�#� c����� sn�%����wi�zFU��D����-����5����2�s���n)�b�[�ˏ'AW�/O��zG��A�~�����?B�C2M?�œ�����B�_9�������8�8ݫ�fТ'����<F�M&f�_^�q\K���\�Ŏ��+���4\z��z���/��ט�&��|i�Ԉ�I��V���\�FH�ٮ�����ڂ}h辎�cQ��,�7�wϪ�|�]_��3����g���ե�C,��Z�R�	�t��0�li����\Z��\pQG6}$�
�3��O�ԅUȟ��B���K�U�G��0�E]�P�e_x�N��
}RQ�}&�l��&�F�h�d�rŴ���8
���:������kI!������e*�lJ��1
�$+(5�Q�^��v�e���^|h�+�F�����閫��ϖF��T̎�|�7�mí8�LY)��4ˀy+�!H[K��W���vn��8������.#O�I����*�t�,K���q
�c�P�{@�$T�.��̺{W{���v��)�M���6��4�!�:?Cފ,�^߂�AHE�]��ZN��Rv]�̟��e
�p�q��Fߥ`_�<́�)ԪD�m���R{�0'
-�&{?���[�ٽ����<L�p6�p�<ѭUH���2���,G�-&�����j�v�-�s=�^�T������Ӹ|�P[sc�%u�T�c�p��zAw,u��R��4�eТFYK�Bl�T���ݽ���h�!�"&$�B��A�"�[E1�w6lr�Ow�؃�6�a
b�gz�J��t���)u��YA�
�ٙ����� �����`5�S��.^�{+��8]L��i��P��Տ
���Z>Y��
Z#{���)��y�ל����w2p�k�=���Tn�Ɔ)N��ȫ�9u.�O�F����o(�l
+�Cey@�Ƨw�;"^��\Xn�J|�E���B�N�����E���`���>��-Ֆ��eG�d�}ˁ�i*�?}�Φ�K�����}�ELT���^��̈v��ͣw�y�����)V���k�����Kw�	/��=��!�q}�{�_w������uR���Ӌb�����M����
>�{Q����o��T�b)\o���>�ԠO��dk�j�ɿ���w�<�OU^���d��yp��}���x#�������1��㗵���eс��������`z�}��(+Cε�&?��"�j�|�ll�&P���؁0��v��"{+�j��H���ښ�i�
a�~A���E@5��$zUw~@e�5��kQ�RU��������c�e��c�d|��-j���<�P��v��3�7�MQYeaWsd�K�m����T�
B�j򴯦����ճ3���<k��;o��֮բ���G+G<�1�T�cl�4���qy�=>�$�bl�ް��EL�:��/毫%�@F�a�īG~���D �G*��ӎYF��s�z�(C�ԏ9cǓѵ�J�^M��ǂ��ϥ�_@gK�aN�A�Gj�:tU���eq82Ӵ�A�Ū�*+q3�����ܴ���c�)���l6
���h���.G{]6���
Wt�љ��N#ʽ���v�ȜN4"0�|�/[j��M����1Ex��BhCGUU�i8<�{�L(e��gev�:iVa�lԘ�
U�<�έ[�2*���m���m�"Y#�1�a�����HS��w��,�����N�`"�Z��"X|��l��i�2��8$Ub�
�/��t�����bz�-0x42 
�+�����wTZ
; }5�I?�T����"'��]f�1M�i)����ׁ�{��d�WҳD������L9e�'G�kB��1i���xG\���"\��A^V:+�?�;�g��Y �jXԯ��{�P�#B֩Z`񘍚�q�P��U6����+ՙE9���^��/�&b�l�Y��SS�nj��:L��8S����C?Y"\?qڏ[9пP�~~1F�t�_�!��+�fA�{���{6�.`NF��*gO�,!���y����/���D�uA�Y�Dc���tď[�*�����`6�`�|�a	���22� G/~i�"��뮴��RŁ�"�i�8��:�O�3�R�㡵�|@��a�]2�Q�^�S�yI'��,�
�\N�{�q�ä6Vf��@�������'���R�G�+��6lZG9��զ��[�t�̛#D���fN��p���o���㝰���Kym����a�w&��G0 �b	Z�}[�{��"�E�o�u&��
�'\���w�>"]5)c�$�����5K���}�&f��6���Ri�QQt�����gL��Br~����l�j��e"���OC��$�`]h���K2�70q\��f�p�N]w����}l
u��Ն���1S&����?`c<Et�����[���Y�����1k~c�J�j� �L��6F�L��n�$�;9]��u�-?��\����E�T�B�����2=W3�4N��ǩ޸=(C&�6t�.�7?k>Ж}
�c�S���˗	�Wμ4�BL�P�����qD^=���d��3t�g�V���ݯ/�~T:70�����3m)�7���MuΝ�DR��\%?�7��ת{��/�]o���t
o��l[�w^:t|�ټ#�L�����N���,A�*��Q#p����W�)���<��"6ؒYc���lN�x}��c��2,�@�޺��̫O:sج=�թ6��=���+���FvaD����>J����k���U|4]~y�Lc-ך�d�����l�F��Vy�v�~z��0�*� �y�'�'��$�C�,F�G��/)�ӁxA}�^�ja�heO�;`�s�L���J*��zV�@�#۞�e��W�[����e����{3n(1Nŷ+P�ئ8��5���,��=�Lǀ�]~���wA{"�K�#'�M�kO���se�$3� =��¯k��ʁ�3M��+P��@�R3����%"
3�z��E��B��=��ʷ(��0��Jo��	ڜI�K��F6�4�p|�t��"tò
F]���k�<w^X���V�?�����qp�Mz�T����e���v���Ņ~h���-�Y3����EW�f�n���
9E��V���\a�x ۪@j�۪���`�������Mt��|�)�U�2��|�U��*��&�
���E�+���o�͚�׉d|��Sr��J��.�rf�,j(3a���b�җ�׊�)��;��RЌ�<$R�����4:A��,��Ԍ�.�+�@�����)
�0T�����$�w��p��C�z��� �@��G��,�7��mQU-��Z-��h�tͶ�ã���4��Žu,(�s}�T؋
2�ˇZV�ɣPL�(%9����r֯�R����W֙60
�M�Ii�Y��#��)'8Qd8A�v ��9��e�B���e�Y�V��W��s�Z�]��sf[���:�ٚ�x/c��q8���ƞ��8��/=�N9��b�<�Vm;��W"����d���<Hn�\���w.�JQb�Um[�xh�p�OQ�d���rC�6f={��
��ch@����-�ٜA͓	e"��-�c��K��\N�0��90��|��`����Y�!��b�j���%����0^}��@�Dp4;U��M~O[28E?Vv�
�K�s1]�z>�6����$�+��n�B�;�Hjo[��AK�z؍�la���FvK
�=j���#_�P�օ��Ӯ WS0�E%�r�R`IJ��U���|�
��TJf�3\,�LM0��H5�B���(C<b�3L��Î�6�b�O�x�:��YpJ+�;V���UY�N���_��2w?�,��t�w��ԅc�T}��a
��_�����u�ཋ �?dqR!3�l�j	S=5qw�UC�QU��%Wʒa�>o�<2!6����T�4��Q;��ްp�2#3È<�\�)j
vć���@2lI�kNC�$�S���T��j�7��:��l5�Z�<�қ(h����5�扜�ē���i��ëH��;ꤗ�Snypd��Z%���A�#�U���
���$�4��(��RjO���
�
\���4R�4��S�Hl_�+��d�=���aB��Mqk�o��;���9O�r�ed����i���a[z_���_�>|��t�.� �C}*�I,� 
J��Q�b��!�3^����v�8S木�]�9�@��b���b}ߗ�z�i&,���2]�=Ý+_�8,��n����q�Y&�>���
"�
�9�eI�a��m��\��W�ב���S	i�6Iك�?Fo�P ����c���˨仴�
	�Y�"��t=�=��ZI�I����}i� �DlZ�Ť3">�UO� z�	�V��Z��x��[H=Ad��BDFӰ��z�M�k�%�2��R����b[�������0��\����Rr�a ��q!�N(rnͻ�\'X� �"�m��J��Q'�w��ZǏ���"��И��IA�Lu���+�Tp�ג �A��O��.���6:-2k���o�n^��Wӟ�!6���ݤ��2�XߔbJ쿸����tJ�{[7��^�`>������mQ�~"�(���Q�"�iU�%KR}�f�������dY����]j+#���'�@z�b��԰ey�������1t'����\���:*���%�te�<BL`���'��1~,A��=^�۰��xS-?B�d41R��Q3���1=]Ƕ���
����M?�Z�(�Cj���n�A�nj08�$䴃��
RSy¥�Ik�~D=��p{v�XR��,���m���t�Z7M�x7O�Oq�{1H�fݎj��+��un�����-�uy(�jHM=-�{��ͷ��J��,��<o�r�n�ʅ�vbB@?���O!sh`��SΌs���P�%��l�6�I�"�c)�!�@J����r���H���������w��n��.Z�È>�:��G�{�Ƴ4��K.��[#���i+�W����e_-Z?-��m�0����-a۞�����ɹfn}��[)��ا=���E�p��x8�����({Ô\�����>����l�)����'�w�!n�vw���m]i*2�#�Zyn@(잢+O�tn$�����MuRG7�xhz�Й�sҚ�Ù�x�M��E�W" ���=��ѣDб�H�ek8�������A���o�8Dc�7�t��672k�:zc�H�
�����M�xꝯ޺�j(��O��зW${�a�vo�/�ʞv<^G2w�J�[mk�L��ۉ�F�K!��s��bz�L�$i����C�eOl�LUp�=Ư�dLZ*yg�2y�`W��[�U�
([���f�N�|�b�q�S�5���6��h}|

���L5�E�
�A���ٝ�o?1J����E��K����s�ix�{�����w~���p�<v�v�����e�iJ�$Ry%�_��W'0U���gh����e���|4�m���W*�s��.��2�m�|��¿���{�������j�6F@�z�)_y%�/�)�c��+X���U�$�E
���\k�VT/~��/��Rj�T����mzZت�����b����񂬿�m�"L��ǯ���	v.�p!o�g'6�\u�{l؂+�ݠk�>�ݺZ�;����+\�9���7��~��wqU��I`R��5�U~�R�qm��F�X�xڮe({��
Y�}�m��jK��!�%bi�	�C\��&�b��iň���2H�@M<����42���$�i&5��u�
MWN:h�15���`��.��#-C-}h��TC�g���y��r�4-���ƺE_w$n-�\�R��l��H��WGn�.���:B��"j����e�G�y!h��Փo��e]�-�`�����m�x&x�{l�i��'����)<�q�h�0�S�r�b��+��E��#j�t�
��Ec�2� �=�:1���E��/>�>�?���.)}��V��6�Q�o��]���X�>uJ�.�j�_��u�2+]+R5��O��)�L�7�i�1�:u|���8+�(��!�7�M~�i��3���c�\�:��s�}��,�9m��m�
R%K�Ϋqk+Mχ�d���pN�|̬B�l��"��M*�����>9h��@� w1�<;��$2x�yuD������<�;s��\�e�s�t�[�C=$����M�X���������MD��ETaatv��W�Γo�N�R��r�%���"�����y
�i:4J>$.�tu]�DRD�m�"��2��'ek \�!�Z\y���s��Y�ꋋUE�����v���&�
C��2q����z��4y	�� p�G��o���eG��Ȣ1�Hi� �2f��Awٲ[Aq	��
G���������v����d�Ni����_�I�Z�
2W�(�:��'Tk�?y�<c_��28><3̪F�¾T|�z��g)����Lnp�?4��1�.�X6�
�Z���
� ܒeXU��3b13�&Z�D������5u
ƍ�^e����Y5%v�W�g�U�H,�y*1y�t�T#K�'�߼����(x���b*�V�R��o4��Y#�ޮm���f�#����j���67�"��q��;Ou��Π�ٟ����vG����TJ�0�J��	k�9�������D�\=�b���
u���o؊��'�E��}QK5�A�4\b@!�#�>�JyF
��
L-�N7��GA�n�N�d����WH���m�\�8C�kY����&s�aQWO�kE+A��y@�w���6=�X	��G���y|��T�B�����P8���/�����x5n�m焰��U|��ˆ��t=�3-6iʴ��1���@��mH9�K0�vuX\"/�9�}|�n���KU�e�n��|\0E��4���}�u�=�:���_���E�#UJN��B6p���
r��rJU��{���t��0*�
н�۴�w�)��R,��vz�F�RE:es�ͩ�|^x$��~x�g���C\Q����)ګ�F|���r.K���Y9Q
����N��-�����^ط������6Hp�XA'*oȂ�Y��n���n�>	t;��W���ؿ�E��FqK�jn�8z
�,��C}��f�y�Bz�����_�
f��`{���^����|ǟ��&�`'&�+^ϭ�χ"q� ��#a_Cpi B&�h��B����ϥ����L5ﮀj@�گ�O�5_�z����ď͏�O��!����Q[�z�t�ːs6��hT�����6�V�V�1NϣSRP03���+��)@7��szk���Tԡ�* @���m��Dv? t�?.��h�b�zFfVf=ce�}F}}6}#c#�#6y���SCzFFV##B�6��� ��C@�����I��- ����5�!�;% �`�|�� � � p5 ����6�M7�-?T	 ,��"� j�|�@��c?� ����P
'@<��
�"bf`D���ň���{uO�9��}b�R	�.X�x�g�GG�b��vf]�w��\֘��ƨ��d�b��1ע1]�:�4��ŴY�W��4)�)lDFQ�/�f���'g P7Oow/�ȓ� @��M�!З;���{��/r`�IT�d��+|B ��f��W��Lo2Mk������^)���Z�7�#�4�l�-�S��6%)���^�L�z+���ܯJ뉆��Z>WI�WqMmB�p�;D�2��^�Jƻ�����#�ۑ��BS��J ֑�'���Yb
��$L~a�Jm��FsYU��_1Z�c�.Z����b�\#����  �cW�P�F�t���'q�#x�xI ���0����h�z2X{^��2S:��D�`l�^|�+��]�����ם�bQU��[�(9H�7n��5p�w�i(^xg�����]Z�7h�c�'_���x?��^|鎎��u���v���e��F҈�y�����Y13���Y133�5bfff�̹����#���;��Օ��*sUwuo5a@����M�����؞��\q�I�~*O�J(��Zi�����p�����K�@�҇����9q_�hB`
��5���rY��eߌ��~ú-�'>Hj�Zӻ5��)���Y��s	��æ�2��+���˃ܜNC��@�!�}�t��cO��l���`6e���0���bl�U_5�Ɠ6�7�Q�iߢi��������:��'x��G����a��d눁X�OG�qI]�A┊����� r�X�(�^��ͫ�@�����Y���-RR��@�AE�'?��ơ��N=��0�e!s�l(��������ۧ|�y�ڑ����i|�l��U7���0"��	�q�qx��e�j�f���H�Mu��Ψ�@�ۘ`����X*ͽ'2���6�	
Ճ�i�-�?��M)�"i�;{#=� �bɈ�g�wP�YY����+M��lw��a��/�*�i���1��?k�����NsFPg�n=�RS����<D��#�+��V@؋��wY�dɫX�Q�H3oh�n�m��].�:h�_@[4l��st�0Y�h�cqw�)�0B�*;��]f�L�;�!k����V��$e�]�?3��azq�y���
T���د��`�+J�J��ĳ��ڼ���fP�L��������K-P����[�**�!��t�MǯR�.V FZL��"�q��G@P�m�Ӕ���(��t���H�3��d�P�z��+�4���
eń��}B�	`|c´j�ʫp���]9`���3-;��󵤄�V��TL���J����C��W��|�*w#jlcC�\�ɑ
���;|�2ͱ#�,�� �
��~����f"�J�1�����W��rN$�c�E����(v�h����+JnÖ	�|_��A"'#N[�?g@�d!hk쎀�22��SKk��#���R�
�d����C*��V��tQ�,��/���gׯw���>�.h8���~q`^��N��&���w�����Ts��D�u%�+��9�S�~�2&|�1#�%�ؤ�.l����/0<̞'4(ƍ!� ��Nw��w��ֆ�7��F�` �G�M@�K;����*Nr���[+�K�d���V$UD֫���k��5.���N�^A��:�������; +|Q����������U�Iq�%��I3i�{�e�z���-npe�m��(3d�2����(Fw�J��Ẅ�k�O�YR��ƦI0�h�<b�w�#~�å�j��HX8�!�;�/>�/l�P{�$�F�q��
D\�_d����"��F՗��(nOo�'��U�����w�2:��pN�w֥-Y`G��qN��ּ�������ye��Z�(��=e��@W9���^��%�fc�dͥ\s��ik ���Q{r�k�փ\�T0¦�Ls�2Ɗ ��v���+
%�Qi�
Y�,G�z��0'ĩ�cPp�{湿�Zf������� �is�Tc���%��f1�m��)c�"���Ao����b�]Jj��`�C�ڣ��TH�I焪�*j��eO�e�P�6��j��
vS�!,c�h�fA��xD9o���BuT�:���n8+xbdx<�(-�+?&���XQ�v��?��g���0�Z�r���hT�H;�Wf�o����lp�'��_ޚV���nۇ��[6}��w3�	)o_���G�'F�^_jo�����)�=[x�n�9�=pz�:X/A��%�:�����H���B���*�3�֠�q������z�h����:b��D�*�rV=VDr=q.ps2��6���}��K���oj�-E*�-K��j���^\E�3�8b�)#xu�;��:}u�)��~�kjwD�A�k?]�����b���,�e}<Z�)�wr�6ޟ{?�*V+z��v�Z�!��]6�;)1�g��wN 3}���V0H�\$���#Fi�/��}ϛ���r'����(�^�+Fӫ�/}���a�W+��J�ط�\7c$����=�T�Zh�ھ�;�W�_J�C�M��Cz�X����l�	��\%y9-
 !�"�_�{��K"Z؟�����	D�X�䬵�bp�+�K*'�e�}�{o%��[v}6����-�5�ގ|�7�ʞo���i&���N������E�ͮ�س��n��f���3�B����+Y�r0q�ϜO�%*���o
�T�v����I�El����ߍNc2���"c�$�epC7�,�#�}8�yJIU8	�hH��Ε�<.^.ǫ�@7��]X�mpdw��A�$�ӣ��� +�Y��a��,����G1��o��$&C��͑�L���ͦ���&���+O<%5
#��7Z(}�h�x9I3�:�,���˞3�%�/�{ LGn��Bn�?���?�"����ĞxQ�Ӗ��p�Fl#?����8{�@�<��Z��G�7'���Ӓt��V�2�H|��s��K@z��������E7�3����z�4��ަ�Sxy��P9��y�k���Y���k\AKm��B��sX�ZW�?�HZJƕ��8hV��'�m%K:+��x����L�8��e�h5�S��c��CHv�����Y��f�����ǜ~�$"M�&!��p*��xJ����L��K���v��K���I�[ܘ�K��S8�D�vIKp�^���f��q#tm*+�S�毒�Ǫ��֒�W"Ua%o.z ��l�&N&o��K�z}H�&�ЭH/�+�)�?���ή�w��)��oczO�	�C$��ݶ��R��qRL�%��l�^;�M��6�l̢��/R�������U���4#ʆ�^�'���<M~��"Ҹ�A�~m�m4n&��7�����Ȁ[e���v���VOI1�A�,!�e:�R������wJ�pf�Q���/��ͺzK��B�=ӷY���ɊX�@"?�6/�8��$���RR`"zr%/N7�qu�<� V$���	���٪˻P�к���o�i���:A�zXv`K?�hĺ���r�=�3�X����+#$��B�^���mhͻ���\�?�����J�e��E-ӘᴩM&���ȣD}�<*Sm�1}TU�>{n�{����ֱ{�PTv�uvfy0dɛh�Re� �M�X�!78�f�c��9Ѣu�YC��Yb��#[�!��&1�1L^6�f�*w��=]rE"����֚�a,���
�pf%*gG�a�V9H�y�!�v�7�����;��C�H��!���l��Q�
Zj������CS�i���|_�:��/�JR��p����j��`m��ĥ���f�!`5lG����<^F>x��� �H���:x���f����QQKg�zh���Mc&[�1im��h�����觪c
����H��X'��~����/i6�ǡ�VZ6^�_�3]���^��R�<[=�flB��9kbnPV��e=�&���ѡc�;�Q���86/�F�%�iD>&?���,)��Aљ[����5�y��7΍�ȯ��Ѽ���^Z&��q�_
�7H�J�*$k�M��e��i��G�_�p�2�����K�Gόw7��t�6�](�%�s���̶��5�D��e��CH٭�\� &.��Clw�9��;O/d�o��Z�Wj�y�v�/�C�He/oqUY(ͮ��y�Ot��N�)�'�[6;�*���a3v�jT�N�	&d���_3�͂c������n�]��7lD��ó}4#��杫c1���O�d��gz�.���q�vZ�-4b���մ�Z��OX���=w�)~ DY����1-�J�]��!R5y���=b�W�l���̼]���m�oH��%�����z��[�ޅ���d�N��#k~�c�sn������(��+�I�D֫qoɉ����ю����n}!��=�zH�%Z�X�V���ࣛ�K�E 6��I�Ep�IНySۮ�\��ml�1�j��]ᩪQ���$v�s�AӀ
�];�?��I�
�:+ĩ4Y��h��WuWF�������㐥i�A���ӛXp`-"� ��T^���^������Qa�f�R�U��mJ?za�;B�д�����<��O�2�%���·��E��04�Φ�$B��O�t����?��ŧ�D��Ohl����,�TpM������9��a�a�ˡ7 V����φJ\�q>³$�DXk�&����䩢U[��8�����}�����'X����\�T��1�oF�\� �ZM鈹�D
�u9�;.޳C�w��im�\��gy+)6giH���{�q��.<�\Ra&}C��?Z�K�8��ޙ�a��
yV���Ňs.V+TL}�����V��j:kp�m�+�>H�L��Ҷk?ɘ���|;�[�ek�:�����;��A�jW%� ����B��>Y֢ճ�G�d�7�����0��

������?ޯ��x!�=?t�u�{!K�tr=�F:��~ʄ\����l	q��%�}/1`��F�d���ypD^VJ}'V��N�,?;=�_�;@	�[aO�Q����[#wPR�n���6���iSj2o��Ÿ���
�?�^ҷ"xFiH
�>P_H�?9�qm�=�
��<0�
k�Rl �$ �ǰ�����ư��TW�1^�APw�g�'�.����K�����7-�cH�@]{C�.;Y�}нs�u�l��=�g��=kc�6�l��"�UN ��|��E����g|��ӎ����얄LB#��~b�������]~�d��ŝ�rk9y~;��9n*r����m1f��j#�`���.�m����ؙ��u����	�-��m&CCDYQ�\��W�����"�;�e#'�EU^R��;�����V���.+z�}ċm�7����^5ˣv,TqU���A|k4�+����c�,mQ���M�0����P��[}S�Hq��݉n`���� o֩}s���sUe�ŕt��6�7��G�pL���,�i��d`Xx���_�ZU�G��x4��-W�����F��c�z�J���ͥC-�c��Q���7��o��֫`��2=>MMʔw���g�n1�
�:��O����o7����-*P���!D��#��Il���cG�;;(G͆ϙ]�}�
pA͗4�!o��l%9L6ע+� ���[�v�:(v�o����(q�0�l��h�]���LА��Srx�`�/U_�:��Ό5��R���s��-��>�_��̫w��-�{<�$p��u* �����׭	Pd����ɂPA�󾱪@�!���1C�j�+~+%[���"�׼!����Y�z�ę��$���C�Z���T�fB�d�W��������2�5�m�K��J%��9(�i����;���!'PP�O�j��3n`G,�QE�����f��^�A�h��XMQ�
4�i>�/�/a�cQ�N���@�f�x����u���۞%���
���b�|Xoh�0iӶۨ/�,�6ZJ-Ziw�&�?|�ܡ�W�S�7��@Q�M/
^�V=*�	4`��Th�3�H �*��Qm^'���vf?��=pd�6���3+�n|�:�̀/ cH�T��fHRϠ6�g'�P ER�쵻��L?��gڣߪ,�"�s�!�+�u�x3��Bl�����
�)�)cw(7�����v��x����3�dԆ�MO��ڔ����}@_��(Td�|�>�%"/��������@��Ҟ /��bK�a��;
��d�����(���6g�I ���妫�W�6V�%��m!�B)3��L�B��������J�/!��)�ɺ� J������c��̘��k\CW�E\��_���A���}K�u-7@��O@8�rÚF��"<ǸL�Z`�����m���	M��n��u�Z'-@��]���0�y�ʻ�Vg���Itc��v�T�XB]ܥ��6~�'��u@�z���K��f@�����ǵp�*l��\ x2�2�1�~�F
h͝jk�
���4O�+�m�
��[���Z�RK<5�4}c"�وQ�/Q��i�1��� RJ�3�N\���X�t�����������j�Tի��`S7���L�/�Ֆ� �e5Z	M��uJ��"N�'��;��-�V���y�h���H?y�� ����j��,3]�=!/`Ev�:XN
D�Y{	cw�P:��s�E����ͰPl|T�u�Q&�=.#TW��1���p���k���DEN6\��h1�^����(z�����[�� _e�H��t�`lc�z��)��0��IE%�7�"�=�_�H,vt�%�$9gj��-O[	�\��ھ��!���jV�����M�މ%RS������	 \&������_"lpT��;��n<�5��`p�������v��E�!Y+� n$�b�,Z��X�%��~I9�ɥ�<���'�,����Hq��ٙ~_�+-����?o��#?�`K�Q��T���X�H�~�K�e:לT�6��,���vrm�=�2�x��=J�k��2%�/��C�U�
�[��[ވ�֪l?Q��	���?#�s������i�p�dGT�q�����
W���p%��>+s4_�bD�f�0r��
1 V Ҁ�|o��ҕ���RWx�8�
(��4����������g�-`�	K?M���z���b#��Ғ��$錹��J�iap_S���n������A��z�]�P��>�M�DMf}�S}�^���ߙ�9�Hiʎc!�=ٽ�и�潁p)�����Z�����XČz��>��گ�W��XZ��o�����y�	4Rbp�e:���`vF	$����T��j+@���uԋ�>ޒ���t�{�Y���*|�h|����k֊��&+X����Z��1'�*��T��
���5|�k+9��3����P�<#�ݏ�<���NQ��r�q'䙬�����E&
�?�/�z�O��%����!���`~y@J �0��b��B��t����`�������s��� �x����l|��|��t��=�5=o|�<����2���)�qDS�t���S�nn,Zڬ`5�=�~Ⴊ����<�xt/Ĉ	���Wx�!��@�޶J�
�}�R_M����_i6�<Q}�3�o}
^�j|��T��Ng��j%���Eўb���Wz���!9�-X�%=y�?U+W�����fzni� ��VK����\�)
!7�SaC�E��6�3�^���`H	�VJ�$~E"<�nx�c�+�B�4������L90%.��%����� �O:k��"Fa3�+S��ή�}����W�����B��ѵѣt�-5���m`LX�(�I"=ccW���>��(:/�T��
j�ܼ6�{f�9�O��9'�U�����*�I5��RWW�?8��t�N���
�2���a���aW%`��S&
R7�>�N\�tz�?X��`J��0��I������d�|2R�a\�x�F�cĶw%��$)��m�����!r��ox���Y�.�ءq��x�D/�Չ`��i�7���
@��O�V�$;r��Of��3�sv�~����!i�^�6=ʩwm���6{���;\K4
H�g�K��4��1J�}H
~M�L����uF(�q{̀R�6
�Blq.���fY�hB}�i���=x�N����9&�7F�Ѝ} ��*�����=�M�S�30NJ�"U��h0Ze��>\9��+ojI��[�d���C[�8�����$����V7�_�JQX�R����t�#<�	��{ѳ��ˑ�6X����*�H?]�4��� �s�G���2�(�v�	
�;�����;UO.Ԇ�b3M]�gG��7�Z|C��?u�J�첲�"�v����H���c �Z���=*�(ߤ�_A=տ4dVf���ȳ|3%�jL)����؋E �N x���Ԑؚ�ث7�q�0��φk�A�igu��yǸݛ��[ʦ��P�C�=�e�u����Q���Ўs<�m����q+�F����
��-�ҁ%�1�K�����69�;Co;^���}�θ�+���_��b�s��ͨ,�|��NtH�姘�c�1)��!��V:h2U�8S�؟�B�tPǹ�K,jڃ6>�QG
s����P9�v�^��k�8M�I�5�i���7���_�߸��1XkX82�����<"��U��.��Xp��s5�h2����u�9���a�(<gچ_�5�Rk{�6��4��2� �\��8�]	�Eg88M4�"�~y�HC��C\(�E2�#J�b���o~����nm�]�8:��Y%F��W� ��AK�B"����<�b�րsE�O��u2#�Q֗[�d�K�ׁͭ�n�BAz�\�
j�-����{�L���۾A��))#� ��x��m�P5�:�t�+�3��[6zxt�cq��eףκ���e���yȺyC��[#r�I�8�o��G�sJ���ӯͥ�������M�n�V�	�|L*,�%/���
x��+��p�l�J�a�p�]��4�����꜄ȑ���sxOW�Ϣ�w�"�E)��(��m���uŞ�bcQ�&u� #����?���qe�3�A�� $�/�M�Z��"Q'W����k�E.!��A�Ėh=��ʥ�'�+��G<��0ru���pj�⇅nK^���ŀ^�Ǵ��CsW�eF��P��gx�+�#��r&m�!�'Y���ܫ,KN/��2���_�(��|����|��e�h[�b��/o�eL4�-�#2ؠ[���l��u�1G��8���DO��a��=2�)���X�P�$��l3��Vr?я֌�B5&ҟ��f0�����w4t��������Z�&��W��� j�ˋ'�+	�F�P(�&;����N�ڊ�������ڽ���8']��b,g�݊Zg*��l�Fk�CR����V3"W����	��ɽ>��E�[���u�Ŧ�fΆs�d?���BѶЛA#d;���D,������|JFvV�*yY_^��F@4�d�&�Z��nOY����s�1˯(1;�T����]~%�x�!vs{k��%�[~�9;<�S��eC�ߎa�"�~��_x��H׷�H������	��Իi�!]�a�� ���<�gj�6�
�������������%�Ո�8q��Ø��WM��^5�t�z(�����ic�l���r�~T��L>gW�}�vW{	���^�!�3\�2�6#)��2X%u�����]k6Uc��XFe����/�&��O�������-�?��]�y�d��'n��>"�6B�ڍlPx�Gl���kv�Q+�AC+G�Ck����e3��Ǉ}(&���
�KU����sC�j���1n9�>�2���	�KB̃��#KVP!�5���� [/X��t�$�,��鬬�絹Ƥ�!�]�L6�,�����Et��Q>�q��O��U���q�IH����<+1J���X�������Q,JE4*
����oUT�N�LT]��Y%�;c�S<��V��CQ@`��ˋ%� ;�yA����%i��fĉ*��k�+�w��+%��I7��Ϟ�@� m�-�U�
W��~�#
r�n��7���R�I�Iś:���Eqqv��(�`��Ǐ�BFf)_���2�*�Q(���P��͊ڱ��
�BpWxn��{@y��#iݩ��OGхW��Թ���L�ge|C"W�4
�]7Ӗ~D��I=r�`Y̚3��j����R2R� ����,��Z�a�8��[������k��eV�s�;���j�n�!(�u�R=�A�.��͹%�Fێ2��2��!E�"��]I�˳1�S�r2=�J��'\}�4�Q���������	��B�l��@G9C�x>"�z�tYy�"���߉���\�J�Jm1<��}���=;�,�����B'{x�$wB�{V�]�"3�������+y�:��Y��b��.�G��z0�s�Hɻ�b��������ر��=���I?x� �u+:.�a���b�b�r�u���<Ƃ��h��S`��.ς��NZkX��x�R{B�*���Z0���{��F࿀,b\�E�ذq	��gI���z�R������r͆my���f�V"�A��[Y7�9$s�@��q��@�,X���5��q�C�=:x��&�aK�F=:���p6�L�1�C�ee��Ğ��<St�L��e=��|�?��p�ۉx�CI�d����](}�K��I��č��-af$�r��|�W�`?�	8��W�THɓvYb��Fl9�HguƮf��&�d]��:Q7�2`7�1Z��^6.w9�Ps�Z]�4��;$t�e�ax-��n��m���DNR�j1��~�U=�%����xЛK��a����lI%�U�����lX^��}��R5c�]�k?r;�,�fm�md��r���`���9���~�:�K͏��*�������[Ҡ�J��]�
������V�����d�P�ܪȳ��}������,:A�+���q�DV?����ݩ�-�}����D�Z��N�.`�{l)sk2Z�XX�|�	�Y��@*���sG����"$a�����h$��c���h�h.:e�<?���F���E��>�Æ@EG���V8�^O�<I�����{o�c��4���Z`�*W�/)k�;�v����[�L�5�0x���
�ʢk-K��oZ�
��J3����*]�=^��hw����Qɳ�V���1����&<�
�*[�GQ5��/c����3���F�U0�Lxk��D��UM/���IoѬ�$(t2+����C����oN��ES����s��sK��bnR��q]ؿ��'�؈�<s�b�t8�\��˯�a�e�	A�`2}���j�f0�)Jr��[�hM���/$fea�3��o&{-�M��t�]�(�v�B,:e�o�H[��m3/�[�@���M���4i
����[��"��^}���sآG���i��S���IV)t��S��q��A�+�H��7Mu-
^�X�C)�6�K�IUڱ���%��_��{��G\���R��64~,�@ u��q��T1��X	��?."/<G-�r�82y��йB~�S.�����Cm��Rp��V~����k�z�&��d	a�}��aL�"�K���i̷�U� ���a��Y�7�6�جS|$�WoY�VIi�'��n��#]�M9 �Z�J��6brU��O��I����ڹ.�v��RC�#"`�����b��!o����T==��\^��f���l=��?j*r����3_��B���_�.�Y������$=�2A&�W��9U;�>sAc��
î�,�D���S�_�I"LS�]f�y��4)�.Ћ-!0[��"y��ac�d��C>�Gz��"2GG蛯G8�*�}�%���m�G�h���K�q���o�=|p3o܂&�sjnc}S`F�^6��j$ޝoPԾkv������I� Y^gpLX{���xS���%�TUs;,���
���(:y2������t���s>\2�Y�}��Ei�'����.��M��q�͚��y��%A{ɢ���ބ��t83/w�/���k�8�\�3��o?��k_�M���!��-2'8Ӊ�εi�)9í;4�W�[���4��QZ���ܒ<^^����௩!�L���"b��*�|��Ԝ����p�t}����5LUz��le���V�%TOk XHJts��'^��l�o:��w����~�ùč�ֺ
����'��~}^DD�P
l+ Y�j�9��@B�m�dz).]��Bܑ�h�O���)7
�a?$B 4�
J� �!h��Lق����\
M���vw`������^�h����T:cb��7�����9tVÚ�w>�@�7��hw��{.�#k��,m���M)���c��	۔O̷<Ԓ���	�}��V���
��R����bI�h`��(����������������YNVй�r��e-��l�!*Z��1�܃���ꍇG ����f��!�ew����\�3<p슉󱰺�A�	FO1����#�_�i��*_�9ˁǷlbW���޾%+�#�n�6���� :jUn�4[�eșc����!���.�uf�E��GzhhH���j��[��E����x*��}ٱ���P}�s3���^�E�~�m�E�jj�i�e�����F:�t#!i߷��Q}T7�+���W�3��N��23�0<�D]p;u�r
���G�����ﯰ�وxPiUU�"^C��	RSh)�
)���ח��Zȧ���d%���u�wrs4S����A:(��{1)���*�@�ۃw�����͠n������������TF�G'BwTԘ����2Ϩ��%��a�H�E����뮏@�
S=�-{��!Ņ����r̩�~����ԏ���m샞C����\ B\j�8��qĽ�W� ���
k�86v� 0T-o�ͧ<:W���s6�I���tv	���ժ�{+��}HͲ>�V�,�ɒ��A��3=��ٹ�L2�84����N8.�J��ɯd�v��2J�XE�/%��#�(ʅ(��zJEE�Ӊ3mŴ�`��?ybggڋCq~r�%�a��}�z^�j|eg�)��)f���W����|�a{�
 (;Ll�Ml�m� ��V� '[�����Ϳ�
Bmmz&&-)B(�?|2��gҷ1���������/��"��"��"� !E�?�(�(ɋ�*��K�?��I׃���ŋ`d�׌����!�ǿ�����"�O���l���;Y ��ȟ? '���^���q�26����K���F��9�:�������FԱ1v��4 }������?%�}�dEԕJ�"�PV��F�WZ��J;�����g ��K��/��T$�/jN �����+�g�?׈=�[2^�M��������k(�.�߳����k��,�'�~[m��̄��Vu��������~[�'5@�3����}���u�q6���s���j��i��_�"�~[�����ſG� �����5 ���wX��GT��������~R�O��\�̭~K��l���%%���ߪ��g�T���<����Oq��w��e�����ҿ��w؟N����9��g��y7�[������|u�q����I����Lߓ���ά����)c���o��m[�o+�m9�~�[��~+[�Ǒ���[��m��ퟑY������L��#���oS�?."��������`n��d��_�a���W����o�Dc�;����[��
@�������N RR�������w��{k7w������F�&&�m�&����~[8�}k��Gc��tXhD�8�~?(44��9�������NfF�����7ɿ'd�=��"�������� @@F # �!����l�kd2 yEeYE��,@DUDQCY��F��K -�*АS(�dT����@��)���?��������?���������r� � 