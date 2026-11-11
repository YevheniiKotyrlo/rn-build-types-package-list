#!/usr/bin/env bash
# Exit 1 while the release variant fails to compile on the debug-only library's package in PackageList.java, 0 once
# both variants compile, 2 when another step fails.
set -u

here="$(cd "$(dirname "$0")" && pwd)"
app="${here}/ReproducerApp"
package_list="${app}/android/app/build/generated/autolinking/src/main/java/com/facebook/react/PackageList.java"
missing_package="error: package com.debugonlylibrary does not exist"

system="$(uname -sm)"
if ! node_version="$(node --version 2>&1)"; then
    echo "step failed: node --version: ${node_version}"
    exit 2
fi
if ! java_version="$(java -version 2>&1)"; then
    echo "step failed: java -version: ${java_version}"
    exit 2
fi
echo "${system}, node ${node_version}, ${java_version%%$'\n'*}"

if ! install_output="$(cd "${app}" && yarn install --frozen-lockfile --non-interactive 2>&1)"; then
    printf '%s\n' "${install_output}"
    echo "step failed: yarn install"
    exit 2
fi
if ! react_native_version="$(cd "${app}" && node -p 'require("react-native/package.json").version' 2>&1)"; then
    echo "step failed: reading react-native's version: ${react_native_version}"
    exit 2
fi
echo "react-native ${react_native_version}"
echo "== modules/debug-only-library/react-native.config.js"
cat "${app}/modules/debug-only-library/react-native.config.js"

echo "== ./gradlew :app:compileDebugJavaWithJavac :app:compileReleaseJavaWithJavac --continue"
build_output="$(cd "${app}/android" && ./gradlew --no-daemon --console=plain :app:compileDebugJavaWithJavac :app:compileReleaseJavaWithJavac --continue 2>&1)"
build_status=$?
build_lines="$(grep -E "^> Task :app:compile(Debug|Release)JavaWithJavac|PackageList\.java:[0-9]+: error|^BUILD (SUCCESSFUL|FAILED)" <<<"${build_output}")"
awk '{ sub(/^ *[^ ]*PackageList\.java:/, "PackageList.java:") } !seen[$0]++' <<<"${build_lines}"
if [[ -f "${package_list}" ]]; then
    echo "== the lines of PackageList.java that name the library"
    grep -n "debugonlylibrary" "${package_list}"
fi

debug_compiled=false
if grep -qE "^> Task :app:compileDebugJavaWithJavac( UP-TO-DATE)?$" <<<"${build_output}" &&
    ! grep -q "^> Task :app:compileDebugJavaWithJavac FAILED" <<<"${build_output}"; then
    debug_compiled=true
fi

if [[ "${build_status}" -eq 0 ]]; then
    echo "SUMMARY: the debug and release variants both compile"
    exit 0
fi
if [[ "${debug_compiled}" == true ]] && grep -qF "${missing_package}" <<<"${build_output}"; then
    echo "SUMMARY: buildTypes ['debug'] keeps the library out of the release classpath, but the release variant's PackageList.java still names com.debugonlylibrary.DebugOnlyPackage, so compileReleaseJavaWithJavac fails"
    exit 1
fi
printf '%s\n' "${build_output}" | tail -n 40
echo "SUMMARY: the build failed for another reason (exit ${build_status})"
exit 2
