import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/stores/opening_editor.store.dart';

class MessageEditorPanel extends StatelessWidget {
  final OpeningEditorStore store;

  const MessageEditorPanel({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mensagens do Instrutor",
              style: GoogleFonts.michroma(color: Colors.white, fontSize: 13),
            ),
            Observer(
              builder: (_) => IconButton(
                icon: const Icon(Icons.add_comment, color: Colors.cyanAccent, size: 20),
                tooltip: "Adicionar Mensagem",
                onPressed: store.currentPath.isEmpty ? null : store.addMessage,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white10),
        Expanded(
          child: Observer(
            builder: (_) {
              if (store.currentPath.isEmpty) {
                return const Center(
                  child: Text(
                    "Faça um lance para adicionar mensagens.",
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                );
              }

              if (store.currentMessages.isEmpty) {
                return const Center(
                  child: Text(
                    "Nenhuma mensagem nesta posição.",
                    style: TextStyle(color: Colors.white24, fontSize: 13),
                  ),
                );
              }

              return ListView.separated(
                itemCount: store.currentMessages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: store.currentMessages[index],
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Digite a dica aqui...",
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: const Color(0xFF222222),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => store.updateMessage(index, val),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () => store.removeMessage(index),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
