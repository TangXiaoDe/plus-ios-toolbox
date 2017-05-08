//
//  TestsInt+Extension.swift
//  AiLiToolbox
//
//  Created by lip on 2017/5/3.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//

import Quick
import Nimble
@testable import AiLiToolbox

class TestsInt_ExtensionSpec: QuickSpec {
    override func spec() {
        describe("需要一个字符串数字数组时") {

            let numberStringArray = "1,2,3"

            it("能从数字数组转换后获得") {
                let numbers = [1, 2, 3]
                let convertNumberStringArray = numbers.convertToString()
                expect(convertNumberStringArray!) == numberStringArray
            }
        }
    }
}
