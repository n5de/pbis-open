#
# Copyright (c) Brian Koropoff
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the MakeKit project nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.
#

_object="$1"
_source="$2"

_mk_define_name "$MK_CANONICAL_SYSTEM"
EXTRA_CPPFLAGS="-I${MK_STAGE_DIR}${MK_INCLUDEDIR} -DHAVE_CONFIG_H -D_MK_$result"
_mk_define_name "${MK_CANONICAL_SYSTEM%/*}"
EXTRA_CPPFLAGS="$EXTRA_CPPFLAGS -D_MK_$result"
INCLUDE_CPPFLAGS=""

case "$COMPILER" in
    c)
        CPROG="$MK_CC"
        FLAGS="$CFLAGS"
        MK_FLAGS="$MK_CFLAGS"
        ;;
    c++)
        CPROG="$MK_CXX"
        FLAGS="$CXXFLAGS"
        MK_FLAGS="$MK_CXXFLAGS"
        ;;
esac

for _dir in ${INCLUDEDIRS}
do
    case "$_dir" in
        /*)
            INCLUDE_CPPFLAGS="$INCLUDE_CPPFLAGS -I${MK_STAGE_DIR}$_dir"
            ;;
        *)
            INCLUDE_CPPFLAGS="$INCLUDE_CPPFLAGS -I${MK_SOURCE_DIR}${MK_SUBDIR}/$_dir -I${MK_OBJECT_DIR}${MK_SUBDIR}/$_dir"
            ;;
    esac
done

MK_MSG_DOMAIN="compile"

if [ -z "$DISABLE_DEPGEN" ]
then
    mk_mkdir ".MakeKitDeps"
    _mk_slashless_name "${_object%.o}"
    DEP_FLAGS="-MMD -MP -MF .MakeKitDeps/${result}.dep"
fi

if [ "$PIC" = "yes" ]
then
    EXTRA_FLAGS="$EXTRA_FLAGS -fPIC"
fi

mk_msg "${_source#${MK_SOURCE_DIR}/} ($MK_CANONICAL_SYSTEM)"

mk_mkdir "`dirname "$_object"`"
mk_run_or_fail ${CPROG} \
    ${INCLUDE_CPPFLAGS} ${MK_CPPFLAGS} ${CPPFLAGS} ${EXTRA_CPPFLAGS} \
    ${MK_FLAGS} ${FLAGS} ${EXTRA_FLAGS} \
    ${DEP_FLAGS} \
    -o "$_object" \
    -c "$_source"
