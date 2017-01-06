## Copyright 2017 Matthias Stübinger
#
# This file is part of the Telex feed-reader.
#
# This program is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see http://www.gnu.org/licenses/.
#
###

# project name
    project (telex-reader)

    # the oldest stable cmake version we support
    cmake_minimum_required (VERSION 2.6)

    # tell cmake where its modules can be found in our project directory
    list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
    list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)

    # where we install data directory (if we have any)
    set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

    # what to call that directory where we install data too
    set (PKGDATADIR "${DATADIR}/telex-reader")

    set (APP_NAME "de.tum.in.stuebinm.telex")
    set (GSETTINGS_PATH ${APP_NAME})
    set (EXEC_NAME "telex")
    set (RELEASE_NAME "A simple reader of feeds.")
    set (VERSION "0.1")
    set (VERSION_INFO "Just a few first tests …")


     # generate a constants.vala file, to be used within the application (as a sort of replacement preprocessor macros)
    configure_file (${CMAKE_SOURCE_DIR}/src/constants.vala.cmakegen 
                    ${CMAKE_BINARY_DIR}/src/constants.vala
                    NEWLINE_STYLE UNIX
    )
    
     # generate a constants.vala file, to be used within the application (as a sort of replacement preprocessor macros)
    configure_file (${CMAKE_SOURCE_DIR}/gsettings/telex.gschema.xml.cmakegen 
                    ${CMAKE_BINARY_DIR}/gsettings/telex.gschema.xml
                    NEWLINE_STYLE UNIX
    )
    
     # copy the gresource directory into the build path
    add_custom_command (OUTPUT ${CMAKE_BINARY_DIR}/gresources/resources.xml
                        COMMAND cp -r ${CMAKE_SOURCE_DIR}/gresources ${CMAKE_BINARY_DIR}
    )
    
     # generate a header file for resources
    add_custom_command (OUTPUT ${CMAKE_BINARY_DIR}/gresources/resources.h
                        DEPENDS ${CMAKE_BINARY_DIR}/gresources/
                        COMMAND /usr/bin/glib-compile-resources --generate-header resources.xml
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/gresources
    )

     # generate a source file for resources
    add_custom_command (OUTPUT ${CMAKE_BINARY_DIR}/gresources/resources.c
                        DEPENDS ${CMAKE_BINARY_DIR}/gresources/resources.xml
                        COMMAND /usr/bin/glib-compile-resources --generate-source resources.xml
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/gresources
    )

                        
                        
    # we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
    find_package(PkgConfig)

    # now let's actually check for the required dependencies
    pkg_check_modules(DEPS REQUIRED 
        gtk+-3.0 
        gee-0.8 
        libxml-2.0 
        webkit2gtk-4.0
        libsoup-2.4
    )

    add_definitions(${DEPS_CFLAGS})
    link_libraries(${DEPS_LIBRARIES})
    link_directories(${DEPS_LIBRARY_DIRS})


    # make sure we have vala
    find_package(Vala REQUIRED)
    # make sure we use vala
    include(ValaVersion)
    # make sure it's the desired version of vala
    ensure_vala_version("0.16" MINIMUM)

     # add translations
    set (GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}")
    add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
    add_subdirectory (po)


    # files we want to compile
    include(ValaPrecompile)
    vala_precompile(VALA_C ${EXEC_NAME}
        src/main.vala
        src/application.vala
        ${CMAKE_BINARY_DIR}/src/constants.vala
        src/feedreader/feedreader.vala
        src/feedparser/atomfeedparser.vala
        src/feedparser/rssfeedparser.vala
        src/feedparser/feedchannel.vala
        src/feedparser/feeditem.vala
        src/feedparser/feedperson.vala
        src/feedparser/feedparser.vala
        src/gui/mainwindow.vala
        src/gui/mainwindowheader.vala
        src/gui/entrydisplay.vala
        src/gui/newslistitem.vala
        src/gui/newslist.vala
        src/gui/newslistmenu.vala
        src/gui/newslistplaceholder.vala
        src/gui/feedlist.vala
        src/gui/feedlistitem.vala
        src/gui/feedadder.vala
        src/gui/settingsdialog.vala
        src/gui/widgets/webimage.vala
        src/gui/widgets/htmlview.vala
        src/gui/widgets/linkbutton.vala
        src/gui/widgets/listitem.vala
        src/helper/download.vala
        src/helper/xml.vala
        src/helper/time.vala
    
    CUSTOM_VAPIS
        gresources/resources.vapi
    
    # tell what libraries to use when compiling
    PACKAGES
        gtk+-3.0
        gee-0.8
        libxml-2.0
        webkit2gtk-4.0
        posix
        libsoup-2.4
    OPTIONS
        --thread
    )

    # compile all the vala-c-files as well as the resource c file (generated above)
    add_executable(${EXEC_NAME} ${VALA_C} ${CMAKE_BINARY_DIR}/gresources/resources.c)


    
    # # # # # # # # # # #  - - - Stuff for installation - - - # # # # # # # # # # #

    # install the binaries we just made
    install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
    
    # install the gsettings scheme
    install (FILES ${CMAKE_BINARY_DIR}/gsettings/telex.gschema.xml DESTINATION ${DATADIR}/glib-2.0/schemas)
    
    # print out a little message
    install (CODE "MESSAGE (\"-- Compiling the gsettings scheme\")")
    
    # compile the gsettings scheme
    install (CODE "execute_process(COMMAND /usr/bin/glib-compile-schemas .
                                   WORKING_DIRECTORY ${DATADIR}/glib-2.0/schemas)"
    )

    # install our .desktop file so the Applications menu will see it
    #install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/hello.desktop DESTINATION ${DATADIR}/applications/)
