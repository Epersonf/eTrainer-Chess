# eTrainer Chess App

## 📦 Stack de Tecnologias

- **Dart/Flutter**
- **MobX** para gerenciamento de estado
- **AutoRoute** para navegação
- **JsonSerializable** para serialização JSON
- Integração com microsserviços via REST
- CI/CD baseado em GCP

---

## 🚀 Primeiros Passos

### 1. Instalação das dependências

```bash
flutter pub get
```

### 2. Geração de código

```bash
dart run build_runner build --delete-conflicting-outputs
```

Com watch:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 3. Exemplo de Store com MobX

```bash
part 'document.store.g.dart';

class DocumentStore = _DocumentStoreBase with _$DocumentoStore;

abstract class _DocumentStoreBase with Store {
  @observable
  bool aprovado = false;

  @action
  void aprovar() {
    aprovado = true;
  }
}
```
