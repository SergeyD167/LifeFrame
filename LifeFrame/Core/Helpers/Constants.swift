//
//  Constants.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import SwiftUI

struct Errors {
    static let savingDataError: String = "Saving data error"
}

struct UI {
    static let screen_width: CGFloat = UIScreen.main.bounds.width
    static let screen_height: CGFloat = UIScreen.main.bounds.height
    static let screen_size: CGSize = UIScreen.main.bounds.size

    static let cell_width = UIScreen.main.bounds.width - 32
    static let chapters_spaces: CGFloat = 32
    
    enum PopUp {
        static let stats_image: String = "settings-pop-up"
        static let editing_image: String = "editing-pop-up"
        
        static let editing_title: String = "No longer editable".localized()
        static let editing_text: String = "You have 24 hours to edit your memories. When the time is up, the editor is blocked. This helps preserve the original mood and essence of the memory.".localized()
        static let editing_btn_text: String = "Well, so :(".localized()

        static let stats_title: String = "Flower of memories".localized()
        static let stats_text: String = "Keep a diary every day and your flower will grow. Memory will improve. The mind will become sharper. Daily recordings strengthen the neurons of our brain and nourish the flower.".localized()
        static let stats_btn_text: String = "Got it".localized()
        
    }
    
    enum Buttons {
        static let pause_audio: String = "pause-audio"
        static let play_audio: String = "play-audio"
        static let scroll_to_bottom: String = "scroll-to-bottom"
        static let send_inactive: String = "send-inactive"
        static let send_active: String = "send-active"
        static let submit_inactive: String = "submit-inactive"
        static let submit_active: String = "submit-active"
    }
    
    enum Icons {
        static let attachments: String = "attachment"
        static let cross_gray: String = "cross-gray"
        static let cross: String = "cross"
        static let drower: String = "drower"
        static let profile: String = "profile"
        static let search: String = "search"
        static let search_active: String = "search-active"
        static let tag: String = "tag"
        static let trash: String = "trash"
        static let edit: String = "edit"
        static let edit_locked: String = "edit-locked"
        static let video_message: String = "video-message"
        static let audio_message: String = "audio-message"
        static let eye_slash_fill: String = "eye.slash.fill"
        static let incognito: String = "incognito"
        static let passcode: String = "passcode"
        static let chevron_right: String = "chevron-right"
        static let emoji: String = "emoji"
    }
    
    enum Strings {
        static let empty_chapter_text: String = "There are no notes today".localized()
        static let dear_diary: String = "Dear diary,".localized()
        static let draft: String = "Drafts".localized()
        static let cancel: String = "Cancel".localized()

        
        static let privacy_mode_title: String = "Privacy mode".localized()
        static let privacy_mode_text: String = "This will hide the recordings from prying eyes, for example, in public transport.".localized()
        
        
        static let passcode_title: String = "Login password".localized()
        static let passcode_text: String = "Create a 4-digit password to enter the diary.".localized()
        
        static let mood_chart_title: String = "Mood chart".localized()
        static let mood_chart_text: String = "Shows the general mood of your memories. It helps to track the level of emotions.".localized()
        static let mood_chart_empty_text: String = "There is no data yet".localized()
        
        static let words_top_title: String = "Top 10 words".localized()
        static let words_top_text: String = "Frequently used words statistics will help you better track your feelings and experiences.".localized()
        static let words_top_empty: [String] = ["Введите", "дневник", "каждый", "день", "узнавайте", "себя", "лучше", "собирайте", "статистику", "о себе"]
        
        static let emoji_top: String = "Top Emoji".localized()
    }
    
    enum Alearts {
        static let php_alert_title: String = "Access to the photo library".localized()
        static let php_message_text: String = "Please grant access in the settings to continue".localized()
        static let php_primaryBtn_text: String = "Cancel".localized()
        static let php_secondaryBtn_text: String = "Settings".localized()
        
        static let micro_alert_title: String = "Microphone access".localized()
        static let micro_message_text: String = "Please grant access in the settings to continue".localized()
        static let micro_primaryBtn_text: String = "Cancel".localized()
        static let micro_secondaryBtn_text: String = "Settings".localized()
    }
}
