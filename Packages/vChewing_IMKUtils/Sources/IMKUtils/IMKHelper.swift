// (c) 2022 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import Foundation
import InputMethodKit

// MARK: - IMKHelper by The vChewing Project (MIT License).

public enum IMKHelper {
  /// 威注音有專門統計過，實際上會有差異的英數鍵盤佈局只有這幾種。
  /// 精簡成這種清單的話，不但節省 SwiftUI 的繪製壓力，也方便使用者做選擇。
  public static let arrWhitelistedKeyLayoutsASCII: [String] = {
    var result = [
      "com.apple.keylayout.ABC",
      "com.apple.keylayout.ABC-AZERTY",
      "com.apple.keylayout.ABC-QWERTZ",
      "com.apple.keylayout.British",
      "com.apple.keylayout.Colemak",
      "com.apple.keylayout.Dvorak",
      "com.apple.keylayout.Dvorak-Left",
      "com.apple.keylayout.DVORAK-QWERTYCMD",
      "com.apple.keylayout.Dvorak-Right",
    ]
    if #unavailable(macOS 10.13) {
      result.append("com.apple.keylayout.US")
      result.append("com.apple.keylayout.German")
      result.append("com.apple.keylayout.French")
    }
    return result
  }()

  public static let arrDynamicBasicKeyLayouts: [String] = [
    "com.apple.keylayout.ZhuyinBopomofo",
    "com.apple.keylayout.ZhuyinEten",
    "org.atelierInmu.vChewing.keyLayouts.vchewingdachen",
    "org.atelierInmu.vChewing.keyLayouts.vchewingmitac",
    "org.atelierInmu.vChewing.keyLayouts.vchewingibm",
    "org.atelierInmu.vChewing.keyLayouts.vchewingseigyou",
    "org.atelierInmu.vChewing.keyLayouts.vchewingeten",
    "org.unknown.keylayout.vChewingDachen",
    "org.unknown.keylayout.vChewingFakeSeigyou",
    "org.unknown.keylayout.vChewingETen",
    "org.unknown.keylayout.vChewingIBM",
    "org.unknown.keylayout.vChewingMiTAC",
  ]

  public static var currentBasicKeyboardLayout: String {
    UserDefaults.standard.string(forKey: "BasicKeyboardLayout") ?? ""
  }

  public static var isDynamicBasicKeyboardLayoutEnabled: Bool {
    Self.arrDynamicBasicKeyLayouts.contains(currentBasicKeyboardLayout) || !currentBasicKeyboardLayout.isEmpty
  }

  public static var allowedAlphanumericalTISInputSources: [TISInputSource] {
    arrWhitelistedKeyLayoutsASCII.compactMap { TISInputSource.generate(from: $0) }
  }

  public static var allowedBasicLayoutsAsTISInputSources: [TISInputSource?] {
    // 為了保證清單順序，先弄兩個容器。
    var containerA: [TISInputSource?] = []
    var containerB: [TISInputSource?] = []
    var containerC: [TISInputSource?] = []

    let rawDictionary = TISInputSource.rawTISInputSources(onlyASCII: false)

    Self.arrWhitelistedKeyLayoutsASCII.forEach {
      if let neta = rawDictionary[$0], !arrDynamicBasicKeyLayouts.contains(neta.identifier) {
        containerC.append(neta)
      }
    }

    Self.arrDynamicBasicKeyLayouts.forEach {
      if let neta = rawDictionary[$0] {
        if neta.identifier.contains("com.apple") {
          containerA.append(neta)
        } else {
          containerB.append(neta)
        }
      }
    }

    // 這裡的 nil 是用來讓選單插入分隔符用的。
    if !containerA.isEmpty { containerA.append(nil) }
    if !containerB.isEmpty { containerB.append(nil) }

    return containerA + containerB + containerC
  }

  public struct CarbonKeyboardLayout {
    var strName: String = ""
    var strValue: String = ""
  }
}

// MARK: - 與輸入法的具體的安裝過程有關的命令

public extension IMKHelper {
  @discardableResult static func registerInputMethod() -> Int32 {
    TISInputSource.registerInputMethod() ? 0 : -1
  }
}
