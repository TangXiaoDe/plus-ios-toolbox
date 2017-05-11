//
//  TestsDate.swift
//  AiLiToolbox
//
//  Created by GorCat on 2017/5/11.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//
//  TSDate 的测试类

import Quick
import Nimble
import AiLiToolbox

class TestsDate: QuickSpec {

    override func spec() {
        describe("传入一个时间戳") {
            let numberStringArray = "1,2,3"
            it("将时间戳转换成显示字符串") {
                let numbers = [1, 2, 3]
                let convertNumberStringArray = numbers.convertToString()
                expect(convertNumberStringArray!) == numberStringArray
            }
        }
    }
}
