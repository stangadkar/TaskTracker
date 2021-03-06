/*
 * Copyright (c) 2020 by Botorabi. All rights reserved.
 * https://github.com/botorabi/TaskTracker
 *
 * License: MIT License (MIT), read the LICENSE text in
 *          main directory for more details.
 */
package net.vrfun.tasktracker.report.docgen;

/**
 * Factory for building report generators for various formats.
 *
 * @author          boto
 * Creation Date    September 2020
 */
public class ReportGeneratorFactory {

    static public ReportGenerator buildGenerator(ReportFormat reportFormat) {
        switch(reportFormat) {
            case PlainText:
                return new ReportGeneratorPlainText();
            case PDF:
                return new ReportGeneratorPDF();
        }

        throw new IllegalArgumentException("Unsupported report generation type");
    }
}
