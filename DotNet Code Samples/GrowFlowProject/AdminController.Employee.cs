using GrowFlow.Api.Compliance.Service;
using GrowFlow.Model.Persistance;
using GrowFlow.Web.Attributes;
using GrowFlow.Web.DTO.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;

namespace GrowFlow.Web.WebAPI
{
    [AuthorizeUserApi]
    public partial class AdminController : GrowFlowApiController
    {
        [HttpGet]
        [Route("Employees")]
        public List<EmployeeDTO> GetEmployees(int accountId)
        {
            List<EmployeeDTO> employees = new List<EmployeeDTO>();
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    employees = service.GetEmployees()
                        .Select(r => new EmployeeDTO
                        {
                            Id = r.Id,
                            FirstName = r.FirstName,
                            LastName = r.LastName,
                            DateOfBirth = r.DateOfBirth,
                            DateOfHire = r.DateOfHire,
                            SocialSecurity = r.SocialSecurity,
                            EmployeeNum = r.EmployeeNum,
                            VehicleId = r.Vehicle?.Id
                        }).ToList();

                    return employees;
                }
            }
        }

        [HttpPost]
        [Route("Employee")]
        public async Task<CreateOperationResult> CreateEmployee(CreateEmployeeDTO dto)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = await service.CreateEmployeeAsync(
                            account,
                            dto.FirstName,
                            dto.LastName,
                            dto.DateOfBirth,
                            dto.DateOfHire,
                            dto.SocialSecurity,
                            dto.EmployeeNum,
                            dto.VehicleId);

                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = result
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }

        [HttpPut]
        [Route("Employee/{EmployeeId:int}")]
        public async Task<OperationResult> EditEmployee(int employeeId, EmployeeDTO dto)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = await service.EditEmployeeAsync(
                            account,
                            dto.Id,
                            dto.FirstName,
                            dto.LastName,
                            dto.DateOfBirth,
                            dto.DateOfHire,
                            dto.SocialSecurity,
                            dto.EmployeeNum,
                            dto.VehicleId);

                        return new CreateOperationResult()
                        {
                            Success = true,
                            Data = result
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }

        [HttpGet]
        [Route("Employee/{EmployeeId:int}/IsDeletable")]
        public DeletableDTO IsEmployeeDeletable(int EmployeeId)
        {
            //TODO-RS: Fill this in once we know what objects depend on Employees
            return new DeletableDTO
            {
                IsDeletable = true
            };
        }

        [HttpDelete]
        [Route("Employee/{EmployeeId:int}")]
        public async Task<OperationResult> DeleteEmployee(int employeeId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = await service.DeleteEmployeeAsync(account, employeeId);
                        return new CreateOperationResult()
                        {
                            Success = result
                        };
                    }
                    catch (Exception e)
                    {
                        return new CreateOperationResult()
                        {
                            Success = false,
                            Exception = e.Message
                        };
                    }
                }
            }
        }
    }
}