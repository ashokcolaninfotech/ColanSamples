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
        [Route("Vehicles")]
        public List<VehicleDTO> GetVehicles(int accountId)
        {
            List<VehicleDTO> vehicles = new List<VehicleDTO>();
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    vehicles = service.GetVehicles()
                        .Select(r => new VehicleDTO
                        {
                            Id = r.Id,
                            Nickname = r.Nickname,
                            Color = r.Color,
                            Make = r.Make,
                            Model = r.Model,
                            Year = r.Year.ToString(),
                            PlateNum = r.Plate,
                            Vin = r.Vin
                        }).ToList();

                    return vehicles;
                }
            }
        }

        [HttpPost]
        [Route("Vehicle")]
        public async Task<CreateOperationResult> CreateVehicle(CreateVehicleDTO dto)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = await service.CreateVehicleAsync(
                            account,
                            dto.Nickname,
                            dto.Color,
                            dto.Make,
                            dto.Model,
                            int.Parse(dto.Year),
                            dto.PlateNum,
                            dto.Vin);

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
        [Route("Vehicle/{vehicleId:int}")]
        public async Task<OperationResult> EditVehicle(int vehicleId, VehicleDTO dto)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = await service.EditVehicleAsync(
                            account,
                            vehicleId,
                            dto.Nickname,
                            dto.Color,
                            dto.Make,
                            dto.Model,
                            int.Parse(dto.Year),
                            dto.PlateNum,
                            dto.Vin);

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
        [Route("Vehicle/{vehicleId:int}/IsDeletable")]
        public DeletableDTO IsVehicleDeletable(int roomId)
        {
            //TODO-RS: Fill this in once we know what objects depend on rooms
            return new DeletableDTO
            {
                IsDeletable = true
            };
        }

        [HttpDelete]
        [Route("Vehicle/{vehicleId:int}")]
        public async Task<OperationResult> DeleteVehicle(int vehicleId)
        {
            using (var dbContext = new GrowFlowContext())
            {
                using (var service = ComplianceService.Create(dbContext, account))
                {
                    try
                    {
                        var result = await service.DeleteVehicleAsync(account, vehicleId);
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