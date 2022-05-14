// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

interface ICCRouter {
	function sendMsgViaL0();
	function sendMsgViaWH();
	function sendMsgViaAxelar();
	function sendMsgViaConnext();
	function sendMsgViaNomad();
}