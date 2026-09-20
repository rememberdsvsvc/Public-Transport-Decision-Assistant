//
//  SupabaseConfig.swift
//  transport-disruption-app
//
//  IMPORTANT:
//  Paste ONLY the Supabase publishable key here.
//  Never put the secret key, service_role key, or database password in the app.
//

import Foundation

enum SupabaseConfig {

    static let projectURL =
        URL(string: "https://rklzjvwxkdvjawetlzoc.supabase.co")!

    // Paste the value from:
    // Supabase -> Copy publishable key
    static let publishableKey =
        "sb_publishable_t8Bdcdq_UgUvYg5n82-yrA_DgbIOngy"
}
