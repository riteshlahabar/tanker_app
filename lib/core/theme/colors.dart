// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// Lifted verbatim from the appetit design source
/// (`flutter design/appetit/lib/utils/AColors.dart`).
///
/// The palette is the design's, not ours — do not retune these values. The
/// tanker-specific names at the bottom are aliases onto the same colours so
/// screen code can read in the app's own language without drifting from the
/// design.

const appetitAppContainerColor = Color(0xFFF9E3D5);
const appetitBrownColor = Color(0xFF927160);

const iconColorPrimary = Color(0xFFFFFFFF);
const iconColorSecondary = Color(0xFFA8ABAD);
const appSecondaryBackgroundColor = Color(0xff343434);
const appTextColorPrimary = Color(0xFF212121);
const appTextColorSecondary = Color(0xFF5A5C5E);
const appShadowColor = Color(0x95E9EBF0);
const appColorPrimaryLight = Color(0xFFF9FAFF);

// Dark Theme Colors
const appBackgroundColorDark = Color(0xFF262626);
const cardBackgroundBlackDark = Color(0xFF1F1F1F);
const color_primary_black = Color(0xFF131d25);
const appColorPrimaryDarkLight = Color(0xFFF9FAFF);
const iconColorPrimaryDark = Color(0xFF212121);
const iconColorSecondaryDark = Color(0xFFA8ABAD);
const appShadowColorDark = Color(0x1A3E3942);

const appColorPrimary = Color(0xFF1157FA);
const appLayout_background = Color(0xFFf8f8f8);

/// ---------------------------------------------------------------------------
/// Status colours for the order lifecycle. Mapped onto the design's palette
/// so a status chip never introduces a colour the design does not already use.
/// ---------------------------------------------------------------------------

const statusPendingColor = Color(0xFFF0A20C);
const statusAssignedColor = appColorPrimary;
const statusRefillingColor = Color(0xFF7C4DFF);
const statusOutForDeliveryColor = appetitBrownColor;
const statusDeliveredColor = Color(0xFF17A672);
const statusCancelledColor = Color(0xFFE23E3E);
