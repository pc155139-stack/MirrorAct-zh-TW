cmake_minimum_required(VERSION 3.20)
project(MirrorActAirPlayOnly LANGUAGES C)

# MirrorAct links UxPlay's receiver library directly. Its GStreamer renderer
# and command-line player are not needed by the macOS app.
set(UXPLAY_SOURCE "${CMAKE_CURRENT_LIST_DIR}/../../Vendor/UxPlay")
add_compile_definitions(EXTERNAL_DNS_SD=1 UXPLAY_HAVE_APPLE_P2P=1)
add_subdirectory("${UXPLAY_SOURCE}/lib/dns_sd" "${CMAKE_BINARY_DIR}/lib/dns_sd")
add_subdirectory("${UXPLAY_SOURCE}/lib/playfair" "${CMAKE_BINARY_DIR}/lib/playfair")
add_subdirectory("${UXPLAY_SOURCE}/lib/llhttp" "${CMAKE_BINARY_DIR}/lib/llhttp")
add_subdirectory("${UXPLAY_SOURCE}/lib" "${CMAKE_BINARY_DIR}/lib")
