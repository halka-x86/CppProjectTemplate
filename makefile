CXX       = g++
CXXFLAGS  = -MMD -MP -Wall -O3 -std=c++14
ifeq "$(shell getconf LONG_BIT)" "64"
  LDFLAGS =
else
  LDFLAGS =
endif
LIBS      =

# インクルードパスの指定
INCLUDE   = -I./include -I./

# デフォルトではmakefileのあるディレクトリ名を実行ファイル名にしている
TARGET_NAME = /$(shell basename `readlink -f .`)
TARGET_DIR  = ./bin
ifeq "$(strip $(TARGET_DIR))" ""
  -mkdir -p $(TARGET_DIR)
endif
TARGET    = $(TARGET_DIR)/$(TARGET_NAME)

#ソースファイルのあるディレクトリ
SRCDIR    = ./src
ifeq "$(strip $(SRCDIR))" ""
  SRCDIR  = .
endif

# ソースファイルの宣言．ソースファイルディレクトリ以下の全ての.cppファイル．
SOURCES   = $(wildcard $(SRCDIR)/*.cpp) $(wildcard ./*.cpp)

# 中間ファイルを置くのディレクトリ
OBJDIR    = ./obj
ifeq "$(strip $(OBJDIR))" ""
  OBJDIR  = .
endif

# オブジェクトファイル．ソースファイルの.cppを.oに置換したもの
OBJECTS   = $(addprefix $(OBJDIR)/, $(notdir $(SOURCES:.cpp=.o)))

# 依存関係を示す中間ファイル（*.d）を宣言
DEPENDS   = $(OBJECTS:.o=.d)

# ターゲットの依存関係
$(TARGET): $(OBJECTS) $(LIBS)
	-mkdir -p $(TARGET_DIR)
	$(CXX) -o $@ $^ $(LDFLAGS)

# オブジェクトの依存関係
$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	-mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) $(INCLUDE) -o $@ -c $<

# ホームディレクトリも一応見ておく
$(OBJDIR)/%.o: ./%.cpp
	-mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) $(INCLUDE) -o $@ -c $<

all: clean $(TARGET)

clean:
	-rm -f $(OBJECTS) $(DEPENDS) $(TARGET) $(TARGET).exe

-include $(DEPENDS)

# コンパイル&実行
run: $(TARGET)
	cd bin; ./$(TARGET_NAME).exe

# ファイル生成しないターゲットを明記
.PHONY: all clean run
