import 'package:flutter/material.dart';

void main() {
  runApp(SudokuApp());
}

class SudokuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku Oyunu',
      home: SudokuScreen(),
    );
  }
}

class SudokuScreen extends StatefulWidget {
  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  int currentLevel = 1;
  List<List<int?>> board = [];

  // Seviyelere göre başlangıç Sudoku tabloları
  final Map<int, List<List<int>>> levelBoards = {
    1: [
      [1, 0, 4],
      [0, 2, 0],
      [3, 0, 1],
    ],
    2: [
      [1, 0, 3, 0],
      [0, 2, 0, 4],
      [3, 0, 1, 0],
      [0, 4, 0, 2],
    ],
    3: [
      [1, 0, 3, 0, 5],
      [0, 2, 0, 4, 0],
      [3, 0, 1, 0, 5],
      [0, 4, 0, 2, 0],
      [5, 0, 3, 0, 1],
    ],
  };

  @override
  void initState() {
    super.initState();
    loadLevel(currentLevel);
  }

  void loadLevel(int level) {
    setState(() {
      currentLevel = level;
      board = List.generate(
          levelBoards[level]!.length,
          (i) => List<int?>.from(
              levelBoards[level]![i].map((e) => e == 0 ? null : e)));
    });
  }

  void resetBoard() {
    loadLevel(currentLevel);
  }

  void checkSolution() {
    int size = board.length;
    // Sudoku çözüm doğrulama için basit kontrol 
    for (int i = 0; i < size; i++) {
      if (board[i].contains(null)) {
        showMessage('Tablo tamamlanmamış.');
        return;
      }
      if (board[i].toSet().length != size) {
        showMessage('Satırda tekrar eden sayı var.');
        return;
      }
      if (List.generate(size, (index) => board[index][i]).toSet().length !=
          size) {
        showMessage('Sütunda tekrar eden sayı var.');
        return;
      }
    }

    if (currentLevel < 3) {
      showMessage('Tebrikler! Sonraki seviyeye geçebilirsiniz.',
          isNextLevel: true);
    } else {
      showMessage('Tebrikler! Tüm seviyeleri tamamladınız.');
    }
  }

  void showMessage(String message, {bool isNextLevel = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sonuç'),
        content: Text(message),
        actions: [
          if (isNextLevel)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                loadLevel(currentLevel + 1);
              },
              child: Text('Sonraki Seviye'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int gridSize = board.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Sudoku - Seviye $currentLevel'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetBoard,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                childAspectRatio: 1.0,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int row = index ~/ gridSize;
                int col = index % gridSize;
                return GestureDetector(
                  onTap: () {
                    if (levelBoards[currentLevel]![row][col] == 0) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: gridSize + 1,
                            itemBuilder: (context, number) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    board[row][col] = number + 1;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: EdgeInsets.all(4),
                                  alignment: Alignment.center,
                                  color: Colors.blueAccent,
                                  child: Text(
                                    '${number + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(1),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      color: levelBoards[currentLevel]![row][col] == 0
                          ? Colors.white
                          : Colors.grey[300],
                    ),
                    child: Text(
                      board[row][col]?.toString() ?? '',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: checkSolution,
            child: Text('Çözümü Kontrol Et'),
          ),
        ],
      ),
    );
  }
}
