//
//  LanguageManger.swift
//
//  Created by abedalkareem omreyh on 10/23/17.
//  Copyright © 2017 abedlkareem omreyh. All rights reserved.
//  GitHub: https://github.com/Abedalkareem/LanguageManger-iOS
//

import UIKit

class LanguageManger {
    
    /// Returns the singleton LanguageManger instance.
    static let shared: LanguageManger = LanguageManger()
    private var localeBundle:Bundle?
    
    /// Returns the currnet language
    var currentLanguage: Languages {
        get {
            let currentLang = Locale.current.languageCode ?? "en"
            return Languages(rawValue: currentLang)!
        }
    }
    
    /// Returns the diriction of the language
    var isRightToLeft: Bool {
        get {
            let lang = currentLanguage.rawValue
            return lang.contains("ar") || lang.contains("he") || lang.contains("ur") || lang.contains("fa")
        }
    }
    
    ///
    /// Set the current language for the app
    ///
    /// - parameter language: The language that you need from the app to run with
    ///
    func setLanguage(language: Languages) {
        
        // change the dircation of the views
        let semanticContentAttribute:UISemanticContentAttribute = language == .ar ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = semanticContentAttribute
        UINavigationBar.appearance().semanticContentAttribute = semanticContentAttribute
        UITextField.appearance().semanticContentAttribute = semanticContentAttribute
        UITextView.appearance().semanticContentAttribute = semanticContentAttribute
        UIStackView.appearance().semanticContentAttribute = semanticContentAttribute
        
        // set current language
     
    //    Locale.updateLanguage(code: language.rawValue)
   //     setLocaleWithLanguage(language.rawValue)

    }
    
    private func setLocaleWithLanguage(_ selectedLanguage: String) {
        if let pathSelected = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
            let bundleSelected = Bundle(path: pathSelected)  {
            localeBundle = bundleSelected
        } else if let pathDefault = Bundle.main.path(forResource: Languages.en.rawValue, ofType: "lproj"),
            let bundleDefault = Bundle(path: pathDefault) {
            localeBundle = bundleDefault
        }
    }
}

enum Languages:String {
    case ar,en,nl,ja,ko,vi,ru,sv,fr,es,pt,it,de,da,fi,nb,tr,el,id,ms,th,hi,hu,pl,cs,sk,uk,hr,ca,ro,he
    case enGB = "en-GB"
    case enAU = "en-AU"
    case enCA = "en-CA"
    case enIN = "en-IN"
    case frCA = "fr-CA"
    case esMX = "es-MX"
    case ptBR = "pt-BR"
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case zhHK = "zh-HK"
}
