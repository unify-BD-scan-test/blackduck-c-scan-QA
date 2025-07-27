# Compiler
CXX := clang++
# LLVM and Clang Config
LLVMCONFIG := /opt/homebrew/opt/llvm/bin/llvm-config
LLVMCOMPONENTS := core
RTTIFLAG := -fno-rtti
# Zlib settings
ZLIB_VERSION := 1.2.2
ZLIB_TARBALL := zlib-$(ZLIB_VERSION).tar.gz
ZLIB_URL := https://zlib.net/fossils/$(ZLIB_TARBALL)
ZLIB_DIR := third_party_zlib
# Compiler and Linker Flags
CXXFLAGS := -I/opt/homebrew/opt/llvm/include \
            -I/opt/homebrew/opt/llvm/include/clang \
            -I/opt/homebrew/Cellar/llvm/20.1.6/include \
            -I$(PWD)/$(ZLIB_DIR) \
            $(shell $(LLVMCONFIG) --cxxflags) \
            $(RTTIFLAG)
LLVMLDFLAGS := $(shell $(LLVMCONFIG) --ldflags --libs $(LLVMCOMPONENTS))
CLANGLIBS := \
	-lclangTooling \
	-lclangFrontendTool \
	-lclangFrontend \
	-lclangDriver \
	-lclangSerialization \
	-lclangCodeGen \
	-lclangParse \
	-lclangSema \
	-lclangStaticAnalyzerFrontend \
	-lclangStaticAnalyzerCheckers \
	-lclangStaticAnalyzerCore \
	-lclangAnalysis \
	-lclangARCMigrate \
	-lclangRewrite \
	-lclangRewriteFrontend \
	-lclangEdit \
	-lclangAST \
	-lclangLex \
	-lclangBasic \
	$(shell $(LLVMCONFIG) --libs) \
	$(shell $(LLVMCONFIG) --system-libs) \
	-lcurses
# Source Files
SOURCES := \
	tutorial1.cpp \
	tutorial2.cpp \
	tutorial3.cpp \
	tutorial4.cpp \
	tutorial6.cpp \
	CItutorial1.cpp \
	CItutorial2.cpp \
	CItutorial3.cpp \
	CItutorial4.cpp \
	CItutorial6.cpp \
	CIBasicRecursiveASTVisitor.cpp \
	CIrewriter.cpp \
	ToolingTutorial.cpp \
	CommentHandling.cpp \
	test_zlib.c
# Object Files
OBJECTS := $(patsubst %.cpp,%.o,$(filter %.cpp,$(SOURCES))) \
           $(patsubst %.c,%.o,$(filter %.c,$(SOURCES)))
# Final Executable Name
EXE := clang_tooling_demo
.PHONY: all clean zlib
all: zlib $(EXE)
# Build the final executable
$(EXE): $(OBJECTS)
	$(CXX) -o $@ $^ $(CLANGLIBS) $(LLVMLDFLAGS)
# Compile C++ files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
# Compile C files
%.o: %.c
	$(CXX) $(CXXFLAGS) -c $< -o $@
# Download and unpack zlib if not already present
zlib:
	@if [ ! -d "$(ZLIB_DIR)" ]; then \
		echo "Downloading zlib $(ZLIB_VERSION)..."; \
		curl -LO $(ZLIB_URL); \
		tar xzf $(ZLIB_TARBALL); \
		mv zlib-$(ZLIB_VERSION) $(ZLIB_DIR); \
		rm $(ZLIB_TARBALL); \
	fi
# Clean build artifacts
clean:
	-rm -f $(EXE) $(OBJECTS) *~
	-rm -rf $(ZLIB_DIR)