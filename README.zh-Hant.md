# MirrorAct 繁體中文版本

本專案以 [sopitz/MirrorAct](https://github.com/sopitz/MirrorAct) 0.2.3 為基礎，保留原作者的程式碼、著作權與 GPL-3.0-or-later 授權。這個版本新增繁體中文介面和語言選項。

在 MirrorAct 開啟「設定 → 一般 → 語言」，選擇「繁體中文」，再按「立即重新啟動」。也可以選擇「系統語言」，讓 App 跟隨 macOS 語言。

繁中翻譯涵蓋主視窗、設定、樣式、選單、錯誤訊息、權限說明與 App 捷徑。iPhone／iPad 的 USB 與 AirPlay 鏡像功能沿用原專案。

## 從原始碼建置

需要完整 Xcode、XcodeGen、CMake、pkgconf、libplist 和 OpenSSL 3。執行：

```sh
scripts/build.sh --no-install
```

此分支只建置 MirrorAct 用到的 UxPlay AirPlay 函式庫，不需要安裝整套 GStreamer。建置結果會顯示在腳本輸出；請先測試，再移到「應用程式」。

## Chromecast 裝置搜尋實驗

在 iPhone 與 Mac 都連上同一台一般 Wi-Fi 路由器後，可執行 `scripts/cast-discovery-probe.sh`，用緯來 App 的投放清單檢查是否看得到「MirrorAct 測試電視」。按 Control-C 會停止廣播並刪除暫存憑證。iPhone 個人熱點不適合作為這項測試的共同 Wi-Fi 環境。

此腳本只發布 `_googlecast._tcp` 裝置資訊並接聽 TLS；它沒有 CastV2 裝置驗證、App 啟動或影音接收功能。搜尋成功也不代表可以連線或播放。MirrorAct 正式 App 目前仍只接收 USB 與 AirPlay 鏡像。
