# Directory
TARGET_DIR   = ./bin
INCLUDE_DIR  = ./include
LIB_DIR      = ./lib
OBJ_DIR      = ./obj
SRC_DIR      = ./src
TEST_SRC_DIR = ./test

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
.PHONY: clean

-include $(DEPENDS)
