# Directory
TARGET_DIR   = ./bin
INCLUDE_DIR  = ./include
LIB_DIR      = ./lib
OBJ_DIR      = ./obj
SRC_DIR      = ./src
TEST_SRC_DIR = ./test
TEST_OBJ_DIR = $(TEST_SRC_DIR)/obj

# Environment
CXX          = g++
CXXFLAGS     = -MMD -MP -Wall -O3 -std=c++14
DEBUG_OPTION = -O0 -g
ifeq "$(shell getconf LONG_BIT)" "64"
  LDFLAGS    =
else
  LDFLAGS    =
endif
LIBS         =

# Include Path
INCLUDE   = -I$(INCLUDE_DIR)

# Targets
# デフォルトではmakefileのあるディレクトリ名を実行ファイル名にしている
TARGET_NAME       = /$(shell basename `readlink -f .`)
DEBUG_TARGET_NAME = $(TARGET_NAME)_debug
ifeq "$(strip $(TARGET_DIR))" ""
  -mkdir -p $(TARGET_DIR)
endif
TARGET       = $(TARGET_DIR)/$(TARGET_NAME)
DEBUG_TARGET = $(TARGET_DIR)/$(DEBUG_TARGET_NAME)

# ソースファイルの宣言．ソースファイルディレクトリ以下の全ての.cppファイル．
SOURCES   = $(wildcard $(SRC_DIR)/*.cpp)

# オブジェクトファイル．ソースファイルの.cppを.oに置換したもの
OBJECTS   = $(addprefix $(OBJ_DIR)/, $(notdir $(SOURCES:.cpp=.o)))

# 依存関係を示す中間ファイル（*.d）を宣言
DEPENDS   = $(OBJECTS:.o=.d)

# Default Target
default: $(TARGET)
.PHONY: default

# 最終的な実行ファイルの依存関係
$(TARGET): $(OBJECTS) $(LIBS)
	-mkdir -p $(TARGET_DIR)
	$(CXX) -o $@ $^ $(LDFLAGS)

# オブジェクトの依存関係
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	-mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(INCLUDE) -o $@ -c $<

#
# debug(gdb)
#

# デバッグ用オブジェクト
DEBUG_OBJECTS = $(addprefix $(OBJ_DIR)/, $(notdir $(SOURCES:.cpp=.debug_o)))

# デバッグ用実行ファイルの依存関係
$(DEBUG_TARGET): $(DEBUG_OBJECTS) $(LIBS)
	-mkdir -p $(TARGET_DIR)
	$(CXX) -o $@ $^ $(LDFLAGS)

# デバッグ用オブジェクトの依存関係
$(OBJ_DIR)/%.debug_o: $(SRC_DIR)/%.cpp
	-mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(DEBUG_OPTION) $(INCLUDE) -o $@ -c $<

#
# googletest
#

# Directory
GTEST_DIR       = $(TEST_SRC_DIR)/googletest
GTEST_BUILD_DIR = $(TEST_SRC_DIR)/build
GTEST_LIB_DIR   = $(GTEST_BUILD_DIR)/lib

# googletest lib
GTEST_LIBS      = -lgtest_main -lgtest -lpthread
GTEST_LIB_FILES = $(GTEST_LIB_DIR)/libgtest_main.a $(GTEST_LIB_DIR)/libgtest.a
GTEST_INCLUDE   = -I$(GTEST_DIR)/googletest/include

# src & obj
TEST_SOURCES    = $(wildcard $(TEST_SRC_DIR)/*.cpp)
TEST_OBJECTS   = $(addprefix $(TEST_OBJ_DIR)/, $(notdir $(TEST_SOURCES:.cpp=.o)))
TEST_DEPENDS   = $(TEST_OBJECTS:.o=.d)

# Targets
TEST_TARGET     = $(addprefix $(TEST_SRC_DIR)/, $(notdir $(TEST_SOURCES:.cpp=.exe)))

ifeq ($(OS),Windows_NT)
	CMAKE_FLAGS = -G "MSYS Makefiles"
else
	CMAKE_FLAGS =
endif

# googletest lib
$(GTEST_LIB_FILES):
	mkdir -p $(GTEST_BUILD_DIR)
	cd $(GTEST_BUILD_DIR); cmake ../googletest $(CMAKE_FLAGS); make

# test targets
$(TEST_TARGET): $(GTEST_LIB_FILES) $(OBJECTS) $(TEST_OBJECTS)
	$(CXX) -o $@ $(filter-out $(OBJ_DIR)/main.o, $(OBJECTS))  $(TEST_OBJECTS) $(LDFLAGS) $(INCLUDE) -L$(GTEST_LIB_DIR) $(GTEST_INCLUDE) $(GTEST_LIBS)

# test objects
$(TEST_OBJ_DIR)/%.o: $(TEST_SRC_DIR)/%.cpp
	-mkdir -p $(TEST_OBJ_DIR)
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(GTEST_INCLUDE) -L$(GTEST_LIB_DIR) $(GTEST_LIBS) -o $@ -c $<

test: $(TEST_TARGET)
	$(TEST_TARGET)
.PHONY: test


#
# ターゲット
#

all: clean $(TARGET)
.PHONY: all

# コンパイル&実行
run: $(TARGET)
	cd bin; .$(TARGET_NAME).exe
.PHONY: run

debug: $(DEBUG_TARGET)
	cd bin; .$(DEBUG_TARGET_NAME).exe
.PHONY: debug

clean:
	-rm -f $(OBJECTS) $(DEPENDS) $(TARGET) $(TARGET).exe
	-rm -f $(DEBUG_OBJECTS) $(DEBUG_TARGET) $(DEBUG_TARGET).exe
	-rm -f $(TEST_OBJECTS) $(TEST_DEPENDS) $(TEST_TARGET) $(TEST_TARGET).exe
	rm -rf $(GTEST_BUILD_DIR)
.PHONY: clean

-include $(DEPENDS)
