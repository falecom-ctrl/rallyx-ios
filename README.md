# RallyX iOS (Capacitor)

Casca nativa iOS do app do jogador RallyX — o mesmo modelo do `rallyx-android`: o app
carrega `https://rallyx.com.br/jogador` num WKWebView nativo. Toda mudança no site aparece
no app na hora, sem recompilar.

- **Bundle ID**: `br.com.rallyx.jogador` (igual ao Android)
- **iOS mínimo**: 15.0
- **Plugins**: App, Push Notifications (via Firebase/FCM), Native Biometric (Face ID / Touch ID)
  e o `ShareImage` próprio (`ios/App/App/ShareImagePlugin.swift`, equivalente ao do Android)

> Este projeto foi gerado no Windows e **não foi compilado** (não existe Xcode aqui). Os
> arquivos Swift e as edições no `.xcodeproj` foram escritos à mão — na primeira compilação
> no Mac pode aparecer algum ajuste pequeno; veja "Se der erro" no fim.

## O que você precisa no Mac

1. macOS com **Xcode 15 ou mais novo** (App Store).
2. **Node.js** (18+) e **CocoaPods**: `brew install node cocoapods`
   (ou `sudo gem install cocoapods`).
3. Uma conta Apple. Para rodar no simulador, qualquer Apple ID basta. Para rodar em iPhone
   real e para o push, é preciso o **Apple Developer Program** (US$ 99/ano).

## Passo a passo

```bash
# 1. copie a pasta rallyx-ios inteira para o Mac (sem node_modules) e entre nela
cd rallyx-ios
npm install
npx cap sync ios        # roda o "pod install" e copia a config para o projeto
npx cap open ios        # abre no Xcode  (ou abra ios/App/App.xcworkspace)
```

No Xcode:
1. Abra sempre o **`App.xcworkspace`** (não o `.xcodeproj`).
2. Selecione o target **App → Signing & Capabilities** e escolha o seu **Team**.
3. Escolha um simulador (ex.: iPhone 15) e clique em ▶ **Run**.

Conferir no app: login, navegação no site, biometria (Simulator → Features → Face ID →
Enrolled), compartilhar imagem da partida (perfil → partida do relógio → compartilhar).

## Push (opcional, só em aparelho real)

O backend manda push por **Firebase Cloud Messaging**. Para o iOS:

1. No [Firebase Console](https://console.firebase.google.com) (projeto `rallyx-5dcce`, o
   mesmo do Android) → **Adicionar app → iOS**, Bundle ID `br.com.rallyx.jogador`.
2. Baixe o **`GoogleService-Info.plist`** e arraste para `ios/App/App/` no Xcode
   (marque "Copy items if needed" e o target App). Sem esse arquivo o app funciona
   normalmente, só sem push (o código só liga o Firebase se o arquivo existir).
3. No portal Apple Developer, crie uma **chave APNs (.p8)** e envie ao Firebase:
   Project Settings → Cloud Messaging → *Apple app configuration* → *APNs Authentication Key*.
4. No Xcode, em **Signing & Capabilities**, confirme que **Push Notifications** e
   **Background Modes → Remote notifications** aparecem (o arquivo `App.entitlements`
   e o `Info.plist` já trazem isso; se a capacidade não aparecer, clique em "+ Capability").
5. O token que chega ao servidor sai como `platform: "ios"` (o site detecta sozinho).
   Nenhuma mudança no backend foi necessária — o FCM entrega no iOS via APNs.

Para a versão da App Store, troque `aps-environment` de `development` para `production`
em `ios/App/App/App.entitlements` (o Xcode faz isso sozinho ao arquivar com distribuição).

## Publicar na App Store (quando quiser)

1. Conta no Apple Developer Program e o app criado no **App Store Connect** (mesmo Bundle ID).
2. Xcode: **Product → Archive → Distribute App → App Store Connect** (ou TestFlight
   para testar antes com pessoas de fora).
3. Ficha da loja: descrição, capturas de tela, política de privacidade, classificação etária.

**Atenção à revisão da Apple:** apps que são só "um site dentro de um app" podem ser
recusados (diretriz 4.2, "funcionalidade mínima"). O app tem recursos nativos que ajudam
(Face ID, push, compartilhar/salvar imagem) — destaque isso na descrição de revisão.
Por o app ter login, a Apple também pede **Login com Apple** só se houver login por
terceiros (Google/Facebook); o login por e-mail e senha não exige.

## Ícone e splash

Ficam em `assets/icon.png` (1024×1024, sem transparência) e `assets/splash.png`.
Para trocar: substitua os arquivos e rode `npm run assets && npx cap sync ios`.
O ícone atual é a arte de 512 px do Android ampliada para 1024 — vale trocar por uma
versão nativa em 1024 antes da loja para ficar nítida.

## Sem Mac: testar a compilação no GitHub Actions

O arquivo `.github/workflows/ios-build.yml` compila o app num Mac da nuvem do GitHub
(simulador, sem assinatura e sem conta Apple). Crie um repositório **privado** só com o
conteúdo desta pasta `rallyx-ios` e faça o push: a aba **Actions** mostra se compilou e
guarda o log completo. Não suba a pasta `rallyx-android` nem o backend para esse repositório
(têm chaves e senhas).

## Se der erro na primeira compilação

- **`No such module 'FirebaseMessaging'`**: rode `npx cap sync ios` (ou `pod install` em
  `ios/App`) e abra o `.xcworkspace`, não o `.xcodeproj`.
- **Erro de assinatura**: escolha o Team em Signing & Capabilities; para simulador pode
  usar "Automatically manage signing" com qualquer Apple ID.
- **`Cannot find 'ShareImagePlugin' in scope` / `MainViewController`**: confirme que os
  dois arquivos `.swift` estão no target App (File Inspector → Target Membership).
- **Push não chega**: veja se o `GoogleService-Info.plist` foi adicionado e se a chave APNs
  está no Firebase; teste sempre em aparelho real (simulador recebe push só em Mac Apple
  Silicon com iOS 16+ e configuração especial).
- Mandar o erro exato do Xcode aqui resolve rápido.

## Comandos úteis (na pasta `rallyx-ios/`)

```bash
npm run sync    # depois de mudar capacitor.config.json ou plugins
npm run open    # abre o Xcode
npm run assets  # regenera ícone e splash
```
