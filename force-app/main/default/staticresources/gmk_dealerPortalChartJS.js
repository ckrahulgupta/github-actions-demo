
console.log("---------------Getting into it--------------");

const setAllCharts = (aLA, cLL, c, d) => {

    console.log("Getting into the function");

    const approvedLoanCTX = document.getElementById('approvedLoanChart');
    const customisedLoanCTX = document.getElementById('customisedLoanChart');





    const approvedLoanChartPer = document.getElementById('approvedLoanChartPer').innerHTML = String(Math.ceil((aLA) * 100 / cLL)) + "% </br> Used";

    try {
        const customisedLoanChartPer = document.getElementById('customisedLoanChartPer').innerHTML = String(Math.ceil((c - d) * 100 / c)) + "% </br> Used";
    }
    catch (err) {
        console.log("Error== ", err)
    }



    const approvedLoanData = {


        labels: [
            'Total Approved Loan',
            'Remaining Contract Limit',
        ],
        datasets: [{
            label: 'Total Expence',
            data: [aLA, (cLL - aLA)],
            backgroundColor: [
                '#61734B',
                '#AC754B',
            ],
            hoverOffset: 4,
        }]
    };
    const customisedLoanData = {


        labels: [
            'Customised Loan Limit',
            'Remaining Customised Limit',
        ],
        datasets: [{
            label: 'Total Expence',
            data: [c - d, d],
            backgroundColor: [
                '#61734B',
                '#AC754B',
            ],
            hoverOffset: 4,
        }]
    };
    var options = {
        cutout: '60%',
        plugins: {
            legend: {
                display: true,
                position: 'right',
                labels: {
                    //color: 'rgb(255, 99, 132)',
                    //position:'right'
                    usePointStyle: true,
                    font: {
                        size: 15
                    }
                }
            }
        }

    }
    const approvedLoanChart = new Chart(approvedLoanCTX, {
        type: 'doughnut',
        data: approvedLoanData,
        options: options
    });

    const customisedLoanChart = new Chart(customisedLoanCTX, {
        type: 'doughnut',
        data: customisedLoanData,
        options: options
    });
}

((portalext, $) => {

    portalext.testFunction = (aLA, cLL, c, d) => {
        setAllCharts(aLA, cLL, c, d);
    }
})((window.portalext = window.portalext || {}));