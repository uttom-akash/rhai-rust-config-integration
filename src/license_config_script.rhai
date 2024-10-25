fn inferDefaultConfig(data, state, result) {
    switch (data.current_license_name.to_lower()) {
        "advanced-1" => applyConfigFn(result, "DefaultAdvanced"),
        "ult-cloud-1" | "ent-cloud-1" => applyConfigFn(result, "DefaultEnterpriseCloud"),
        "essentials-1" => applyConfigFn(result, "DefaultEssentials"),
        "free-1" => {
            if data.isLoggedIn {
                applyConfigFn(result, "DefaultFreeWithAccount");
            } else {
                applyConfigFn(result, "DefaultFreeWithoutAccount");
            }
        },
        "lite-1" => applyConfigFn(result, "DefaultLite1"),
        "lite-2" => applyConfigFn(result, "DefaultLite2"),
        "performance-1" => applyConfigFn(result, "DefaultPerformance"),
        "power-1" => applyConfigFn(result, "DefaultPower1"),
        "professional-1" => applyConfigFn(result, "DefaultProfessional1"),
        "professional-2" => applyConfigFn(result, "DefaultProfessional2"),
        "solo-1" => applyConfigFn(result, "DefaultSolo"),
        "standard-1" => applyConfigFn(result, "DefaultStandard"),
        _ => ()
    }
}

fn inferMinimalConfig(data, state, result) {
    switch (data.current_license_name.to_lower()) {
        "advanced-1" => applyConfigFn(result, "MinimalAdvanced"),
        "ult-cloud-1" | "ent-cloud-1" => applyConfigFn(result, "MinimalEnterpriseCloud"),
        "essentials-1" => applyConfigFn(result, "MinimalEssentials"),
        "free-1" => {
            if data.isLoggedIn {
                applyConfigFn(result, "MinimalFreeWithAccount");
            } else {
                applyConfigFn(result, "MinimalFreeWithoutAccount");
            }
        },
        "lite-1" => applyConfigFn(result, "MinimalLite1"),
        "lite-2" => applyConfigFn(result, "MinimalLite2"),
        "performance-1" => applyConfigFn(result, "MinimalPerformance"),
        "power-1" => applyConfigFn(result, "MinimalPower1"),
        "professional-1" => applyConfigFn(result, "MinimalProfessional1"),
        "professional-2" => applyConfigFn(result, "MinimalProfessional2"),
        "solo-1" => applyConfigFn(result, "MinimalSolo"),
        "standard-1" => applyConfigFn(result, "MinimalStandard"),
        _ => ()
    }
}

fn applySessionQueue(data, state, result) {
    if data.current_license_name == "ult-cloud-1" || data.current_license_name == "ent-cloud-1" {
        result.sharedKeys["ad.license.feature.session_queue"] = "1";
        result.sharedKeys["ad.license.feature.session_queue.send_email"] = "1";
        result.sharedKeys["ad.license.feature.session_queue.queues"] = "1";
    }
}

fn infer(data, state) {
  
    let specialLicense = get_special_license();

    applyConfigFn(result, "AccountRollout");
  
    // Special Licenses for QA
    if data.lid != () && specialLicense.contains(data.lid.to_string()) {
        applyConfigFn(result, specialLicense[data.lid.to_string()]);
        return result;
    }

    // Apply rest of configs
    switch (data["system.os_type"].to_lower()) {
        "windows" | "linux" | "macos" => inferDefaultConfig(data, state, result),
        "android" => inferMinimalConfig(data, state, result),
        "ios" => (),
        _ => result.sharedKeys["ad.license.ui.flags"] = "1"
    }
  
    // Shorten Russia trial time
    if data.location.country != () && data.location.country.to_lower() == "ru" {
        applyConfigFn(result, "TrialDuration1Day");
    } else {
        applyConfigFn(result, "TrialDuration7Day");
    }

    if !data.isLoggedIn {
        result.sharedKeys["ad.license.feature.address_book.personal"] = "0";
    }
    
    if data.controlLicense != () {
        if !data.controlLicense.active && !get_ignore_lid_active_status_set().contains(data.lid) {
            result.sharedKeys["ad.license.feature.no_lockdown"] = "0";
            result.sharedKeys["ad.license.feature.lockdown.link"] = "https://portal.com/";
            result.sharedKeys["ad.license.feature.lockdown.info_link"] = "https://support.portal.com/knowledge/license-expired-error";
        }
    }

    // Shorter sessions for Japan, Taiwan, and Pakistan
    if data.current_license_name.to_lower().contains("free") && 
        data.location.country != () &&
        ["ja", "tw", "pk"].contains(data.location.country.to_lower()) {
        result.sharedKeys["ad.license.info.session_timeout"] = "30";
    }

    applySessionQueue(data, state, result);
    return result;
}

fn get_ignore_lid_active_status_set() {
    return [
        1562846768000607, 1583317974617424, 1601540802186035, 1612436830867914, 
        1614954977098527, 1626106858875925, 1634896290678504, 1642190684986041, 
        1591260638630902, 1636358313903149, 1636358313848022, 1569316875582695, 
        1565736190309595, 1634896290674910, 1459578466753894, 1459592948022688, 
        1650466195917467, 1650466195927927, 1616518676340921, 1616518676340138, 
        1613740960087028, 1642190684956006, 1621623477919961, 1621623477921991, 
        1623084258442022, 1473859646822562, 1621623477918120, 1533831735839575, 
        1663258558287616, 1634896290668061, 1666477194044808, 1636358313821174, 
        1636358313829667, 1668093777390034, 1668093777396689, 1636358313846652, 
        1636358313841025, 1668093777491259, 1636358313848243, 1668093777574584, 
        1668093777815137, 1607087845988245, 1642190684817608, 1634896290662275, 
        1636358313809337, 1636358313819073, 1668093777760239, 1630422045743844, 
        1636358313869107, 1636358313837257, 1634745849207243, 1612436830870462, 
        1666477193961375, 1678732215931130, 1626106858857643, 1617815282821468, 
        1599762112169880, 1687852318086945, 1687852318365127, 1636358313875042, 
        1636358313861260, 1678732215734848, 1566546039255444, 1636358313812598, 
        1632131818584785, 1626106858859214, 1659965929960362, 1634745849207575, 
        1668093777206216, 1636358313917841, 1696605598004538, 1699571258530354, 
        1699571259055109, 1707491710288696, 1668093779213148, 1707491710852200, 
        1668093777259516, 1699571256991005, 1678732217084988, 1684893946301042, 
        1717601515831195, 1655678681552243, 1717601516972871, 163635831387
    ];
}

fn get_special_license() {
    return #{
        "1485517443175597": "ASTECOLicense",
        "1": "SpecialLicense1",
        "2": "SpecialLicense2",
        "3": "SpecialLicense3"
    };
}
